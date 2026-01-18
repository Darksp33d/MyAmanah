import Foundation
import Combine
internal import PostgREST

// MARK: - Quote Service
@MainActor
final class QuoteService: ObservableObject {
    static let shared = QuoteService()
    
    @Published private(set) var dailyContent: DailyContent?
    @Published private(set) var savedContent: [SavedContent] = []
    @Published private(set) var isLoading = false
    
    private var quotes: [Quote] = Quote.samples
    private var hadiths: [Hadith] = Hadith.samples
    private let supabase = SupabaseManager.shared
    
    private init() {
        loadDailyContent()
    }
    
    // MARK: - Daily Content
    func loadDailyContent() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: today) ?? 1
        
        // Alternate between quote and hadith based on day
        let isHadithDay = dayOfYear % 2 == 0
        
        // Create deterministic index based on date
        let dateString = ISO8601DateFormatter().string(from: today)
        let seed = dateString.hashValue
        
        if isHadithDay {
            let index = abs(seed) % hadiths.count
            dailyContent = .hadith(hadiths[index])
        } else {
            let index = abs(seed) % quotes.count
            dailyContent = .quote(quotes[index])
        }
    }
    
    // MARK: - Save/Unsave
    func saveContent(_ content: DailyContent, userId: UUID) async throws {
        let saved = SavedContent(
            id: UUID(),
            userId: userId,
            contentType: content.contentType == "quote" ? .quote : .hadith,
            contentId: content.contentId,
            savedAt: Date()
        )
        
        try await supabase.insert(into: "saved_content", value: saved)
        savedContent.append(saved)
    }
    
    func unsaveContent(_ content: DailyContent, userId: UUID) async throws {
        try await supabase.delete(from: "saved_content") { query in
            query
                .eq("user_id", value: userId.uuidString)
                .eq("content_id", value: content.contentId)
        }
        savedContent.removeAll { $0.contentId == content.contentId }
    }
    
    func isSaved(_ content: DailyContent) -> Bool {
        savedContent.contains { $0.contentId == content.contentId }
    }
    
    func fetchSavedContent(for userId: UUID) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            savedContent = try await supabase.fetch(from: "saved_content") { query in
                query.eq("user_id", value: userId.uuidString).order("saved_at", ascending: false) as! PostgrestFilterBuilder
            }
        } catch {
            print("Error fetching saved content: \(error)")
        }
    }
    
    // MARK: - Get Content by ID
    func quote(byId id: String) -> Quote? {
        quotes.first { $0.id == id }
    }
    
    func hadith(byId id: String) -> Hadith? {
        hadiths.first { $0.id == id }
    }
    
    func content(for saved: SavedContent) -> DailyContent? {
        switch saved.contentType {
        case .quote:
            if let quote = quote(byId: saved.contentId) { return .quote(quote) }
        case .hadith:
            if let hadith = hadith(byId: saved.contentId) { return .hadith(hadith) }
        case .post:
            return nil
        }
        return nil
    }
}
