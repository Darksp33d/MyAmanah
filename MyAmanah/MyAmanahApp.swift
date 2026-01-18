import SwiftUI
import Supabase

@main
struct MyAmanahApp: App {
    @StateObject private var supabaseManager = SupabaseManager.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    init() {
        configureAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    MainTabView()
                        .environmentObject(supabaseManager)
                } else {
                    OnboardingView(isOnboardingComplete: $hasCompletedOnboarding)
                        .environmentObject(supabaseManager)
                }
            }
            .preferredColorScheme(.light)
            .onOpenURL { url in
                Task {
                    await handleDeepLink(url)
                }
            }
        }
    }
    
    private func handleDeepLink(_ url: URL) async {
        // Handle Supabase auth callback
        if url.scheme == AppConfig.DeepLink.scheme && url.host == AppConfig.DeepLink.host {
            do {
                try await supabaseManager.client.auth.session(from: url)
            } catch {
                print("Error handling auth callback: \(error)")
            }
        }
    }
    
    private func configureAppearance() {
        // Navigation Bar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(Color.backgroundPrimary)
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor(Color.textPrimary)]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color.textPrimary)]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        
        // Tint
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(Color.accentGreenDark)
    }
}
