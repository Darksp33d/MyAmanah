import Foundation

// MARK: - Quote Model
struct Quote: Codable, Identifiable {
    let id: String
    let text: String
    let arabicText: String?
    let source: String
    let category: QuoteCategory
    
    var attributedSource: String {
        "— \(source)"
    }
}

// MARK: - Hadith Model
struct Hadith: Codable, Identifiable {
    let id: String
    let text: String
    let arabicText: String?
    let narrator: String
    let source: HadithSource
    let bookNumber: Int?
    let hadithNumber: Int
    
    var attributedSource: String {
        var attribution = source.displayName
        if let bookNum = bookNumber {
            attribution += ", Book \(bookNum)"
        }
        attribution += ", Hadith \(hadithNumber)"
        return attribution
    }
}

// MARK: - Quote Category
enum QuoteCategory: String, Codable {
    case quran
    case scholar
    case poetry
    case wisdom
    
    var displayName: String {
        switch self {
        case .quran: return "Quran"
        case .scholar: return "Islamic Scholar"
        case .poetry: return "Islamic Poetry"
        case .wisdom: return "Wisdom"
        }
    }
}

// MARK: - Hadith Source
enum HadithSource: String, Codable {
    case bukhari
    case muslim
    case abuDawud = "abu_dawud"
    case tirmidhi
    case nasai
    case ibnMajah = "ibn_majah"
    case malik
    case ahmad
    
    var displayName: String {
        switch self {
        case .bukhari: return "Sahih al-Bukhari"
        case .muslim: return "Sahih Muslim"
        case .abuDawud: return "Sunan Abu Dawud"
        case .tirmidhi: return "Jami' at-Tirmidhi"
        case .nasai: return "Sunan an-Nasa'i"
        case .ibnMajah: return "Sunan Ibn Majah"
        case .malik: return "Muwatta Malik"
        case .ahmad: return "Musnad Ahmad"
        }
    }
}

// MARK: - Daily Content
enum DailyContent: Identifiable {
    case quote(Quote)
    case hadith(Hadith)
    
    var id: String {
        switch self {
        case .quote(let quote): return "quote_\(quote.id)"
        case .hadith(let hadith): return "hadith_\(hadith.id)"
        }
    }
    
    var text: String {
        switch self {
        case .quote(let quote): return quote.text
        case .hadith(let hadith): return hadith.text
        }
    }
    
    var arabicText: String? {
        switch self {
        case .quote(let quote): return quote.arabicText
        case .hadith(let hadith): return hadith.arabicText
        }
    }
    
    var attribution: String {
        switch self {
        case .quote(let quote): return quote.attributedSource
        case .hadith(let hadith): return hadith.attributedSource
        }
    }
    
    var contentType: String {
        switch self {
        case .quote: return "quote"
        case .hadith: return "hadith"
        }
    }
    
    var contentId: String {
        switch self {
        case .quote(let quote): return quote.id
        case .hadith(let hadith): return hadith.id
        }
    }
}

// MARK: - Saved Content
struct SavedContent: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let contentType: SavedContentType
    let contentId: String
    let savedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case contentType = "content_type"
        case contentId = "content_id"
        case savedAt = "saved_at"
    }
}

enum SavedContentType: String, Codable {
    case quote
    case hadith
    case post
}

// MARK: - Sample Data for Development
extension Quote {
    static let samples: [Quote] = [
        Quote(
            id: "q1",
            text: "Indeed, with hardship comes ease.",
            arabicText: "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا",
            source: "Quran 94:5",
            category: .quran
        ),
        Quote(
            id: "q2",
            text: "The best among you are those who have the best manners and character.",
            arabicText: nil,
            source: "Prophet Muhammad (ﷺ)",
            category: .wisdom
        ),
        Quote(
            id: "q3",
            text: "Patience is the key to relief.",
            arabicText: "الصَّبْرُ مِفْتَاحُ الْفَرَجِ",
            source: "Arabic Proverb",
            category: .wisdom
        ),
        Quote(
            id: "q4",
            text: "When you feel lost, remember that Allah's plan is always better than your dreams.",
            arabicText: nil,
            source: "Islamic Wisdom",
            category: .wisdom
        ),
        Quote(
            id: "q5",
            text: "Trust in Allah, but tie your camel.",
            arabicText: nil,
            source: "Prophet Muhammad (ﷺ)",
            category: .wisdom
        )
    ]
}

extension Hadith {
    static let samples: [Hadith] = [
        Hadith(
            id: "h1",
            text: "The strong is not the one who overcomes the people by his strength, but the strong is the one who controls himself while in anger.",
            arabicText: nil,
            narrator: "Abu Hurairah",
            source: .bukhari,
            bookNumber: 78,
            hadithNumber: 6114
        ),
        Hadith(
            id: "h2",
            text: "None of you truly believes until he loves for his brother what he loves for himself.",
            arabicText: nil,
            narrator: "Anas ibn Malik",
            source: .bukhari,
            bookNumber: 2,
            hadithNumber: 13
        ),
        Hadith(
            id: "h3",
            text: "The best of people are those who are most beneficial to people.",
            arabicText: nil,
            narrator: "Jabir ibn Abdullah",
            source: .tirmidhi,
            bookNumber: nil,
            hadithNumber: 2263
        ),
        Hadith(
            id: "h4",
            text: "Make things easy and do not make them difficult, cheer people up and do not drive them away.",
            arabicText: nil,
            narrator: "Anas ibn Malik",
            source: .bukhari,
            bookNumber: 3,
            hadithNumber: 69
        ),
        Hadith(
            id: "h5",
            text: "A Muslim is the one from whose tongue and hands other Muslims are safe.",
            arabicText: nil,
            narrator: "Abdullah ibn Amr",
            source: .bukhari,
            bookNumber: 2,
            hadithNumber: 10
        )
    ]
}
