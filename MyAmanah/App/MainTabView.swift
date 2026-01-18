import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @StateObject private var supabase = SupabaseManager.shared
    
    enum Tab: String, CaseIterable {
        case home = "Home"
        case track = "Track"
        case athaan = "Athaan"
        case spaces = "Spaces"
        case settings = "Settings"
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .track: return "calendar"
            case .athaan: return "moon.stars.fill"
            case .spaces: return "person.2.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label(Tab.home.rawValue, systemImage: Tab.home.icon)
                }
                .tag(Tab.home)
            
            CycleCalendarView()
                .tabItem {
                    Label(Tab.track.rawValue, systemImage: Tab.track.icon)
                }
                .tag(Tab.track)
            
            AthaanView()
                .tabItem {
                    Label(Tab.athaan.rawValue, systemImage: Tab.athaan.icon)
                }
                .tag(Tab.athaan)
            
            SpacesView()
                .tabItem {
                    Label(Tab.spaces.rawValue, systemImage: Tab.spaces.icon)
                }
                .tag(Tab.spaces)
            
            SettingsView()
                .tabItem {
                    Label(Tab.settings.rawValue, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .tint(.accentGreenDark)
        .onAppear {
            configureTabBarAppearance()
        }
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.backgroundPrimary)
        
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.accentGreenDark)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.accentGreenDark)]
        
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.textTertiary)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color.textTertiary)]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    MainTabView()
}
