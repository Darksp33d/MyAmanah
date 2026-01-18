import Foundation

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: UUID
    let authId: UUID
    var displayName: String?
    var birthYear: Int?
    let createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    var isPremium: Bool
    var premiumExpiresAt: Date?
    var avatarUrl: String?
    var timezone: String
    var onboardingCompleted: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case authId = "auth_id"
        case displayName = "display_name"
        case birthYear = "birth_year"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case isPremium = "is_premium"
        case premiumExpiresAt = "premium_expires_at"
        case avatarUrl = "avatar_url"
        case timezone
        case onboardingCompleted = "onboarding_completed"
    }
    
    init(
        id: UUID = UUID(),
        authId: UUID,
        displayName: String? = nil,
        birthYear: Int? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        deletedAt: Date? = nil,
        isPremium: Bool = false,
        premiumExpiresAt: Date? = nil,
        avatarUrl: String? = nil,
        timezone: String = TimeZone.current.identifier,
        onboardingCompleted: Bool = false
    ) {
        self.id = id
        self.authId = authId
        self.displayName = displayName
        self.birthYear = birthYear
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.isPremium = isPremium
        self.premiumExpiresAt = premiumExpiresAt
        self.avatarUrl = avatarUrl
        self.timezone = timezone
        self.onboardingCompleted = onboardingCompleted
    }
}

// MARK: - User Summary (for display in posts/comments)
struct UserSummary: Codable, Identifiable {
    let id: UUID
    let displayName: String
    let avatarUrl: String?
    let badge: UserBadge?
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
        case badge
    }
}

// MARK: - User Settings
struct UserSettings: Codable {
    let id: UUID
    let userId: UUID
    
    // Cycle settings
    var defaultCycleLength: Int
    var fertileWindowEnabled: Bool
    
    // Athaan settings
    var locationLatitude: Double?
    var locationLongitude: Double?
    var locationName: String?
    var locationMode: LocationMode
    var calculationMethod: PrayerCalculationMethod
    var asrMethod: AsrCalculationMethod
    
    // Notification settings
    var notificationSettings: NotificationSettings
    
    // Privacy settings
    var analyticsEnabled: Bool
    var crashReportingEnabled: Bool
    
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case defaultCycleLength = "default_cycle_length"
        case fertileWindowEnabled = "fertile_window_enabled"
        case locationLatitude = "location_latitude"
        case locationLongitude = "location_longitude"
        case locationName = "location_name"
        case locationMode = "location_mode"
        case calculationMethod = "calculation_method"
        case asrMethod = "asr_method"
        case notificationSettings = "notification_settings"
        case analyticsEnabled = "analytics_enabled"
        case crashReportingEnabled = "crash_reporting_enabled"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    static var `default`: UserSettings {
        UserSettings(
            id: UUID(),
            userId: UUID(),
            defaultCycleLength: 28,
            fertileWindowEnabled: false,
            locationLatitude: nil,
            locationLongitude: nil,
            locationName: nil,
            locationMode: .auto,
            calculationMethod: .isna,
            asrMethod: .standard,
            notificationSettings: .default,
            analyticsEnabled: true,
            crashReportingEnabled: true,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

// MARK: - Location Mode
enum LocationMode: String, Codable {
    case auto
    case manual
}

// MARK: - Prayer Calculation Methods
enum PrayerCalculationMethod: String, Codable, CaseIterable {
    case isna = "ISNA"
    case mwl = "MWL"
    case egypt = "EGYPT"
    case makkah = "MAKKAH"
    case karachi = "KARACHI"
    case tehran = "TEHRAN"
    
    var displayName: String {
        switch self {
        case .isna: return "ISNA (North America)"
        case .mwl: return "Muslim World League"
        case .egypt: return "Egyptian General Authority"
        case .makkah: return "Umm al-Qura (Saudi Arabia)"
        case .karachi: return "University of Islamic Sciences, Karachi"
        case .tehran: return "Institute of Geophysics, Tehran"
        }
    }
    
    var fajrAngle: Double {
        switch self {
        case .isna: return 15.0
        case .mwl: return 18.0
        case .egypt: return 19.5
        case .makkah: return 18.5
        case .karachi: return 18.0
        case .tehran: return 17.7
        }
    }
    
    var ishaAngle: Double {
        switch self {
        case .isna: return 15.0
        case .mwl: return 17.0
        case .egypt: return 17.5
        case .makkah: return 0 // 90 min after Maghrib
        case .karachi: return 18.0
        case .tehran: return 14.0
        }
    }
}

// MARK: - Asr Calculation Method
enum AsrCalculationMethod: String, Codable, CaseIterable {
    case standard // Shafi'i, Maliki, Hanbali
    case hanafi
    
    var displayName: String {
        switch self {
        case .standard: return "Standard (Shafi'i, Maliki, Hanbali)"
        case .hanafi: return "Hanafi"
        }
    }
    
    var shadowFactor: Double {
        switch self {
        case .standard: return 1.0
        case .hanafi: return 2.0
        }
    }
}

// MARK: - Notification Settings
struct NotificationSettings: Codable {
    var fajr: PrayerNotificationSetting
    var dhuhr: PrayerNotificationSetting
    var asr: PrayerNotificationSetting
    var maghrib: PrayerNotificationSetting
    var isha: PrayerNotificationSetting
    var cycleReminders: Bool
    var symptomCheckins: Bool
    
    static var `default`: NotificationSettings {
        NotificationSettings(
            fajr: .init(enabled: true, minutesBefore: 0),
            dhuhr: .init(enabled: true, minutesBefore: 0),
            asr: .init(enabled: true, minutesBefore: 0),
            maghrib: .init(enabled: true, minutesBefore: 0),
            isha: .init(enabled: true, minutesBefore: 0),
            cycleReminders: true,
            symptomCheckins: false
        )
    }
}

struct PrayerNotificationSetting: Codable {
    var enabled: Bool
    var minutesBefore: Int
}

// MARK: - Subscription
struct Subscription: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let productId: String
    let originalTransactionId: String?
    var status: SubscriptionStatus
    let purchaseDate: Date
    var expiresAt: Date
    var isTrial: Bool
    let environment: SubscriptionEnvironment
    var receiptData: String?
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case productId = "product_id"
        case originalTransactionId = "original_transaction_id"
        case status
        case purchaseDate = "purchase_date"
        case expiresAt = "expires_at"
        case isTrial = "is_trial"
        case environment
        case receiptData = "receipt_data"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum SubscriptionStatus: String, Codable {
    case active
    case expired
    case cancelled
    case gracePeriod = "grace_period"
    case billingRetry = "billing_retry"
}

enum SubscriptionEnvironment: String, Codable {
    case sandbox
    case production
}
