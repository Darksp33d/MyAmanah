import SwiftUI
import Combine

@MainActor
final class AthaanViewModel: ObservableObject {
    @Published var prayerTimes: [PrayerTime] = []
    @Published var qiblaDirection: QiblaDirection?
    @Published var isLoading = false
    
    private let prayerService = PrayerTimeService.shared
    private var timer: Timer?
    
    var nextPrayer: PrayerTime? {
        prayerTimes.first { $0.isNext }
    }
    
    var locationName: String {
        prayerService.currentLocation?.name ?? "Set Location"
    }
    
    var calculationMethod: String {
        prayerService.todayPrayerTimes?.method.rawValue ?? "ISNA"
    }
    
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        // Default location if none set (will be replaced by actual location)
        if prayerService.currentLocation == nil {
            let defaultLocation = PrayerLocation(
                latitude: 40.7128,
                longitude: -74.0060,
                name: "New York, NY",
                timezone: "America/New_York"
            )
            prayerService.setLocation(defaultLocation)
        }
        
        updatePrayerTimes()
        
        if let location = prayerService.currentLocation {
            qiblaDirection = QiblaDirection(from: location)
        }
        
        startTimer()
    }
    
    private func updatePrayerTimes() {
        if let dailyTimes = prayerService.todayPrayerTimes {
            prayerTimes = dailyTimes.times
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.prayerService.refreshTodayPrayerTimes()
                self?.updatePrayerTimes()
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}

@MainActor
final class AthaanSettingsViewModel: ObservableObject {
    @Published var locationMode: LocationMode = .auto
    @Published var manualCity: String = ""
    @Published var calculationMethod: PrayerCalculationMethod = .isna
    @Published var asrMethod: AsrCalculationMethod = .standard
    @Published var notificationStates: [Prayer: Bool] = [:]
    
    private let supabase = SupabaseManager.shared
    
    init() {
        for prayer in Prayer.prayers {
            notificationStates[prayer] = true
        }
    }
    
    func binding(for prayer: Prayer) -> Binding<Bool> {
        Binding(
            get: { self.notificationStates[prayer] ?? true },
            set: { self.notificationStates[prayer] = $0 }
        )
    }
    
    func save() async {
        // Save settings to Supabase
        guard let userId = supabase.currentUser?.id else { return }
        
        let settings = [
            "location_mode": locationMode.rawValue,
            "calculation_method": calculationMethod.rawValue,
            "asr_method": asrMethod.rawValue
        ]
        
        try? await supabase.update(table: "user_settings", value: settings) {
            $0.eq("user_id", value: userId.uuidString)
        }
        
        PrayerTimeService.shared.refreshTodayPrayerTimes()
    }
}
