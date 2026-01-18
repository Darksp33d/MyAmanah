import Foundation
import CoreLocation
import Combine

// MARK: - Prayer Time Service
@MainActor
final class PrayerTimeService: ObservableObject {
    static let shared = PrayerTimeService()
    
    @Published private(set) var todayPrayerTimes: DailyPrayerTimes?
    @Published private(set) var currentLocation: PrayerLocation?
    @Published private(set) var isLoading = false
    @Published var error: Error?
    
    private let locationManager = CLLocationManager()
    private var settings: UserSettings?
    
    private init() {}
    
    // MARK: - Calculate Prayer Times
    func calculatePrayerTimes(for date: Date = Date(), location: PrayerLocation, method: PrayerCalculationMethod, asrMethod: AsrCalculationMethod = .standard) -> DailyPrayerTimes {
        let calculator = PrayerTimeCalculator(
            latitude: location.latitude,
            longitude: location.longitude,
            timezone: TimeZone(identifier: location.timezone) ?? .current,
            method: method,
            asrMethod: asrMethod
        )
        
        let times = calculator.calculateTimes(for: date)
        let now = Date()
        
        var prayerTimes: [PrayerTime] = []
        var foundNext = false
        
        for prayer in Prayer.allCases {
            guard let time = times[prayer] else { continue }
            let isPassed = time < now
            let isNext = !isPassed && !foundNext
            if isNext { foundNext = true }
            prayerTimes.append(PrayerTime(prayer: prayer, time: time, isNext: isNext, isPassed: isPassed))
        }
        
        return DailyPrayerTimes(date: date, location: location.name, method: method, times: prayerTimes)
    }
    
    func refreshTodayPrayerTimes() {
        guard let location = currentLocation else { return }
        let method = settings?.calculationMethod ?? .isna
        let asrMethod = settings?.asrMethod ?? .standard
        todayPrayerTimes = calculatePrayerTimes(for: Date(), location: location, method: method, asrMethod: asrMethod)
    }
    
    func setLocation(_ location: PrayerLocation) {
        currentLocation = location
        refreshTodayPrayerTimes()
    }
    
    func updateSettings(_ settings: UserSettings) {
        self.settings = settings
        if let lat = settings.locationLatitude, let lon = settings.locationLongitude, let name = settings.locationName {
            currentLocation = PrayerLocation(latitude: lat, longitude: lon, name: name, timezone: TimeZone.current.identifier)
        }
        refreshTodayPrayerTimes()
    }
}

// MARK: - Prayer Time Calculator
struct PrayerTimeCalculator {
    let latitude: Double
    let longitude: Double
    let timezone: TimeZone
    let method: PrayerCalculationMethod
    let asrMethod: AsrCalculationMethod
    
    private let DEG = Double.pi / 180
    private let RAD = 180 / Double.pi
    
    func calculateTimes(for date: Date) -> [Prayer: Date] {
        let calendar = Calendar.current
        let jd = julianDate(date)
        let sunDeclination = sunDeclinationAngle(jd)
        let eqTime = equationOfTime(jd)
        
        var times: [Prayer: Date] = [:]
        
        // Dhuhr (solar noon)
        let dhuhrMins = 12 * 60 - (longitude * 4) - eqTime + Double(timezone.secondsFromGMT(for: date)) / 60
        let dhuhrDate = dateFromMinutes(dhuhrMins, date: date, calendar: calendar)
        times[.dhuhr] = dhuhrDate
        
        // Fajr
        let fajrAngle = method.fajrAngle
        let fajrMins = dhuhrMins - hourAngle(fajrAngle, declination: sunDeclination) * 4
        times[.fajr] = dateFromMinutes(fajrMins, date: date, calendar: calendar)
        
        // Sunrise
        let sunriseAngle = 0.833 // Standard refraction
        let sunriseMins = dhuhrMins - hourAngle(sunriseAngle, declination: sunDeclination) * 4
        times[.sunrise] = dateFromMinutes(sunriseMins, date: date, calendar: calendar)
        
        // Asr
        let asrFactor = asrMethod.shadowFactor
        let asrAngle = RAD * atan(1 / (asrFactor + tan(abs(latitude - sunDeclination) * DEG)))
        let asrMins = dhuhrMins + hourAngle(90 - asrAngle * RAD, declination: sunDeclination) * 4
        times[.asr] = dateFromMinutes(asrMins, date: date, calendar: calendar)
        
        // Maghrib (sunset)
        let maghribMins = dhuhrMins + hourAngle(sunriseAngle, declination: sunDeclination) * 4
        times[.maghrib] = dateFromMinutes(maghribMins, date: date, calendar: calendar)
        
        // Isha
        let ishaAngle = method.ishaAngle
        if ishaAngle > 0 {
            let ishaMins = dhuhrMins + hourAngle(ishaAngle, declination: sunDeclination) * 4
            times[.isha] = dateFromMinutes(ishaMins, date: date, calendar: calendar)
        } else {
            // For Makkah method: 90 minutes after Maghrib
            times[.isha] = times[.maghrib]?.addingTimeInterval(90 * 60)
        }
        
        return times
    }
    
    private func julianDate(_ date: Date) -> Double {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        var y = Double(components.year!)
        var m = Double(components.month!)
        let d = Double(components.day!)
        
        if m <= 2 { y -= 1; m += 12 }
        let a = floor(y / 100)
        let b = 2 - a + floor(a / 4)
        return floor(365.25 * (y + 4716)) + floor(30.6001 * (m + 1)) + d + b - 1524.5
    }
    
    private func sunDeclinationAngle(_ jd: Double) -> Double {
        let d = jd - 2451545.0
        let g = (357.529 + 0.98560028 * d).truncatingRemainder(dividingBy: 360)
        let q = (280.459 + 0.98564736 * d).truncatingRemainder(dividingBy: 360)
        let l = (q + 1.915 * sin(g * DEG) + 0.020 * sin(2 * g * DEG)).truncatingRemainder(dividingBy: 360)
        let e = 23.439 - 0.00000036 * d
        return RAD * asin(sin(e * DEG) * sin(l * DEG))
    }
    
    private func equationOfTime(_ jd: Double) -> Double {
        let d = jd - 2451545.0
        let g = (357.529 + 0.98560028 * d).truncatingRemainder(dividingBy: 360)
        let q = (280.459 + 0.98564736 * d).truncatingRemainder(dividingBy: 360)
        let l = (q + 1.915 * sin(g * DEG) + 0.020 * sin(2 * g * DEG)).truncatingRemainder(dividingBy: 360)
        let e = 23.439 - 0.00000036 * d
        var ra = RAD * atan2(cos(e * DEG) * sin(l * DEG), cos(l * DEG)) / 15
        if ra < 0 { ra += 24 }
        return (q / 15 - ra) * 60
    }
    
    private func hourAngle(_ angle: Double, declination: Double) -> Double {
        let cosHA = (sin(angle * DEG) - sin(latitude * DEG) * sin(declination * DEG)) / (cos(latitude * DEG) * cos(declination * DEG))
        return RAD * acos(max(-1, min(1, cosHA))) / 15
    }
    
    private func dateFromMinutes(_ minutes: Double, date: Date, calendar: Calendar) -> Date {
        let start = calendar.startOfDay(for: date)
        return start.addingTimeInterval(minutes * 60)
    }
}
