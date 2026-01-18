import Foundation
import SwiftUI

// MARK: - Prayer Time Model
struct PrayerTime: Identifiable {
    let id = UUID()
    let prayer: Prayer
    let time: Date
    let isNext: Bool
    let isPassed: Bool
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
    
    var timeUntil: String? {
        guard isNext else { return nil }
        let interval = time.timeIntervalSince(Date())
        if interval < 0 { return nil }
        
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "in \(hours)h \(minutes)m"
        } else {
            return "in \(minutes)m"
        }
    }
    
    var timeSince: String? {
        guard isPassed && !isNext else { return nil }
        let interval = Date().timeIntervalSince(time)
        if interval < 0 { return nil }
        
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m ago"
        } else {
            return "\(minutes)m ago"
        }
    }
}

// MARK: - Prayer Enum
enum Prayer: String, CaseIterable, Identifiable {
    case fajr
    case sunrise
    case dhuhr
    case asr
    case maghrib
    case isha
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .fajr: return "Fajr"
        case .sunrise: return "Sunrise"
        case .dhuhr: return "Dhuhr"
        case .asr: return "Asr"
        case .maghrib: return "Maghrib"
        case .isha: return "Isha"
        }
    }
    
    var arabicName: String {
        switch self {
        case .fajr: return "الفجر"
        case .sunrise: return "الشروق"
        case .dhuhr: return "الظهر"
        case .asr: return "العصر"
        case .maghrib: return "المغرب"
        case .isha: return "العشاء"
        }
    }
    
    var icon: String {
        switch self {
        case .fajr: return "sunrise.fill"
        case .sunrise: return "sun.horizon.fill"
        case .dhuhr: return "sun.max.fill"
        case .asr: return "sun.min.fill"
        case .maghrib: return "sunset.fill"
        case .isha: return "moon.stars.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .fajr: return Color(hex: "5D7A99")
        case .sunrise: return Color(hex: "F4A460")
        case .dhuhr: return Color(hex: "FFD700")
        case .asr: return Color(hex: "FFA500")
        case .maghrib: return Color(hex: "FF6B6B")
        case .isha: return Color(hex: "4A5568")
        }
    }
    
    var isPrayer: Bool {
        self != .sunrise
    }
    
    static var prayers: [Prayer] {
        allCases.filter { $0.isPrayer }
    }
}

// MARK: - Daily Prayer Times
struct DailyPrayerTimes {
    let date: Date
    let location: String
    let method: PrayerCalculationMethod
    let times: [PrayerTime]
    
    var fajr: PrayerTime? { times.first { $0.prayer == .fajr } }
    var sunrise: PrayerTime? { times.first { $0.prayer == .sunrise } }
    var dhuhr: PrayerTime? { times.first { $0.prayer == .dhuhr } }
    var asr: PrayerTime? { times.first { $0.prayer == .asr } }
    var maghrib: PrayerTime? { times.first { $0.prayer == .maghrib } }
    var isha: PrayerTime? { times.first { $0.prayer == .isha } }
    
    var currentPrayer: PrayerTime? {
        times.first { $0.isNext }
    }
    
    var nextPrayer: PrayerTime? {
        times.first { $0.isNext }
    }
}

// MARK: - Location for Prayer Times
struct PrayerLocation: Codable {
    let latitude: Double
    let longitude: Double
    let name: String
    let timezone: String
    
    static var mecca: PrayerLocation {
        PrayerLocation(
            latitude: 21.4225,
            longitude: 39.8262,
            name: "Mecca, Saudi Arabia",
            timezone: "Asia/Riyadh"
        )
    }
}

// MARK: - Qibla Direction
struct QiblaDirection {
    let degrees: Double
    let cardinalDirection: String
    
    init(from location: PrayerLocation) {
        let meccaLat = 21.4225 * .pi / 180
        let meccaLon = 39.8262 * .pi / 180
        let lat = location.latitude * .pi / 180
        let lon = location.longitude * .pi / 180
        
        let dLon = meccaLon - lon
        
        let x = sin(dLon) * cos(meccaLat)
        let y = cos(lat) * sin(meccaLat) - sin(lat) * cos(meccaLat) * cos(dLon)
        
        var bearing = atan2(x, y) * 180 / .pi
        bearing = (bearing + 360).truncatingRemainder(dividingBy: 360)
        
        self.degrees = bearing
        
        switch bearing {
        case 0..<22.5, 337.5..<360: self.cardinalDirection = "N"
        case 22.5..<67.5: self.cardinalDirection = "NE"
        case 67.5..<112.5: self.cardinalDirection = "E"
        case 112.5..<157.5: self.cardinalDirection = "SE"
        case 157.5..<202.5: self.cardinalDirection = "S"
        case 202.5..<247.5: self.cardinalDirection = "SW"
        case 247.5..<292.5: self.cardinalDirection = "W"
        case 292.5..<337.5: self.cardinalDirection = "NW"
        default: self.cardinalDirection = "N"
        }
    }
}
