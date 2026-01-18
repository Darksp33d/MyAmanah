import SwiftUI
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isContentSaved = false
    
    private let cycleService = CycleService.shared
    private let prayerService = PrayerTimeService.shared
    private let quoteService = QuoteService.shared
    private let supabase = SupabaseManager.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Cycle Data
    var cycleDay: String {
        if let day = cycleService.currentCycleDay {
            return "\(day)"
        }
        return "—"
    }
    
    var currentPhase: CyclePhase? {
        cycleService.currentPhase
    }
    
    var phaseTitle: String {
        currentPhase?.displayName ?? "Start Tracking"
    }
    
    var phaseDescription: String {
        currentPhase?.description ?? "Log your first period to begin"
    }
    
    var daysUntilPeriod: Int? {
        cycleService.daysUntilNextPeriod
    }
    
    // MARK: - Prayer Data
    var nextPrayer: Prayer? {
        prayerService.todayPrayerTimes?.nextPrayer?.prayer
    }
    
    var nextPrayerTime: String {
        guard let prayerTime = prayerService.todayPrayerTimes?.nextPrayer else {
            return "Set up prayer times"
        }
        return prayerTime.formattedTime
    }
    
    var prayerCountdown: String {
        prayerService.todayPrayerTimes?.nextPrayer?.timeUntil ?? ""
    }
    
    // MARK: - Daily Content
    var dailyContentText: String {
        quoteService.dailyContent?.text ?? "Loading..."
    }
    
    var dailyContentAttribution: String {
        quoteService.dailyContent?.attribution ?? ""
    }
    
    // MARK: - Recommendations
    var recommendations: [Recommendation] {
        guard let phase = currentPhase else {
            return [
                Recommendation(title: "Welcome to MyAmanah", body: "Start by logging your cycle to get personalized insights.", icon: "sparkles")
            ]
        }
        
        switch phase {
        case .menstrual:
            return [
                Recommendation(title: "Rest & Restore", body: "Your body is working hard. Consider gentle activities and warm foods.", icon: "moon.zzz"),
                Recommendation(title: "Stay Hydrated", body: "Increase water and iron-rich foods to replenish your body.", icon: "drop.fill")
            ]
        case .follicular:
            return [
                Recommendation(title: "Energy Rising", body: "Great time for new projects and social activities.", icon: "bolt.fill"),
                Recommendation(title: "Try Something New", body: "Your body is primed for learning and creativity.", icon: "lightbulb.fill")
            ]
        case .ovulation:
            return [
                Recommendation(title: "Peak Energy", body: "You may feel more confident and communicative.", icon: "sun.max.fill"),
                Recommendation(title: "Connect", body: "Great time for important conversations and presentations.", icon: "person.2.fill")
            ]
        case .luteal:
            return [
                Recommendation(title: "Self-Care Time", body: "Focus on stress management and gentle exercise.", icon: "heart.fill"),
                Recommendation(title: "Nourish Yourself", body: "Complex carbs and magnesium-rich foods can help.", icon: "leaf.fill")
            ]
        }
    }
    
    // MARK: - Actions
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        if let userId = supabase.currentUser?.id {
            await cycleService.fetchLogs(for: userId)
            await quoteService.fetchSavedContent(for: userId)
        }
        
        prayerService.refreshTodayPrayerTimes()
        updateSavedState()
    }
    
    func refresh() async {
        await loadData()
    }
    
    func toggleSaveContent() {
        guard let content = quoteService.dailyContent,
              let userId = supabase.currentUser?.id else { return }
        
        Task {
            if isContentSaved {
                try? await quoteService.unsaveContent(content, userId: userId)
            } else {
                try? await quoteService.saveContent(content, userId: userId)
            }
            updateSavedState()
        }
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func shareContent() {
        guard let content = quoteService.dailyContent else { return }
        let text = "\(content.text)\n\n\(content.attribution)\n\nShared via MyAmanah"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func updateSavedState() {
        if let content = quoteService.dailyContent {
            isContentSaved = quoteService.isSaved(content)
        }
    }
}

// MARK: - Recommendation Model
struct Recommendation {
    let title: String
    let body: String
    let icon: String
}
