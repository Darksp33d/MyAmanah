import SwiftUI
import Combine
import UserNotifications
internal import PostgREST

// MARK: - Update DTOs
struct ProfileUpdate: Codable {
    let displayName: String
    let onboardingCompleted: Bool
    
    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case onboardingCompleted = "onboarding_completed"
    }
}

struct CycleSettingsUpdate: Codable {
    let defaultCycleLength: Int
    
    enum CodingKeys: String, CodingKey {
        case defaultCycleLength = "default_cycle_length"
    }
}

enum OnboardingStep {
    case welcome
    case valueProps
    case auth
    case profile
    case permissions
    case premium
}

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var currentValuePropPage = 0
    
    // Auth
    @Published var email = ""
    @Published var password = ""
    @Published var authError: String?
    @Published var isLoading = false
    @Published var showSignIn = false
    
    // Profile
    @Published var displayName = ""
    @Published var cycleLength = 28
    
    // Permissions
    @Published var notificationsEnabled = true
    @Published var locationEnabled = true
    
    private let supabase = SupabaseManager.shared
    
    func nextStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            switch currentStep {
            case .welcome:
                currentStep = .valueProps
            case .valueProps:
                currentStep = .auth
            case .auth:
                currentStep = .profile
            case .profile:
                currentStep = .permissions
            case .permissions:
                currentStep = .premium
            case .premium:
                break
            }
        }
    }
    
    func signUp() async {
        guard !email.isEmpty, !password.isEmpty else {
            authError = "Please enter email and password"
            return
        }
        
        guard password.count >= 8 else {
            authError = "Password must be at least 8 characters"
            return
        }
        
        isLoading = true
        authError = nil
        defer { isLoading = false }
        
        do {
            try await supabase.signUp(email: email, password: password, displayName: displayName.isEmpty ? nil : displayName)
            nextStep()
        } catch {
            authError = "Failed to create account. Please try again."
        }
    }
    
    func signInWithApple() async {
        // Apple Sign In implementation would go here
        // For now, skip to next step
        nextStep()
    }
    
    func skipAuth() {
        // Allow anonymous usage
        nextStep()
    }
    
    func saveProfile() async {
        guard let user = supabase.currentUser else {
            nextStep()
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let updates = ProfileUpdate(displayName: displayName, onboardingCompleted: true)
            try await supabase.update(table: "users", value: updates) {
                $0.eq("id", value: user.id.uuidString)
            }
            
            let settingsUpdates = CycleSettingsUpdate(defaultCycleLength: cycleLength)
            try await supabase.update(table: "user_settings", value: settingsUpdates) {
                $0.eq("user_id", value: user.id.uuidString)
            }
        } catch {
            print("Error saving profile: \(error)")
        }
        
        nextStep()
    }
    
    func requestPermissions() async {
        if notificationsEnabled {
            await requestNotificationPermission()
        }
        
        if locationEnabled {
            await requestLocationPermission()
        }
        
        nextStep()
    }
    
    private func requestNotificationPermission() async {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            print("Notification permission: \(granted)")
        } catch {
            print("Notification permission error: \(error)")
        }
    }
    
    private func requestLocationPermission() async {
        // Location permission is handled by CLLocationManager in PrayerTimeService
    }
    
    func startTrial() {
        // Start free trial - StoreKit implementation
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
