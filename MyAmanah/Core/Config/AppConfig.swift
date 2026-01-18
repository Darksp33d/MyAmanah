import Foundation

// MARK: - App Configuration
enum AppConfig {
    // MARK: - Supabase
    static let supabaseURL = URL(string: "https://musikxjfmvxeivxeyuen.supabase.co")!
    static let supabaseAnonKey = "sb_publishable_yZ7JluTbLGjr0IUh9BeewA_axoYkJne"
    
    // MARK: - App Store
    static let appStoreId = "YOUR_APP_STORE_ID"
    static let monthlyProductId = "com.myamanah.premium.monthly"
    static let yearlyProductId = "com.myamanah.premium.yearly"
    
    // MARK: - Feature Flags
    static let aiFeatureEnabled = false
    static let spacesCreationEnabled = false
    static let videoPostsEnabled = false
    
    // MARK: - Limits
    static let maxSymptomsPerLog = 20
    static let maxNotesLength = 500
    static let maxPostTitleLength = 200
    static let maxPostBodyLength = 5000
    static let maxCommentLength = 2000
    static let maxSpaceRules = 10
    static let maxSpacesPerUser = 5
    static let maxImagesPerPost = 4
    static let maxVideoLengthSeconds = 60
    static let maxImageSizeMB = 10
    static let maxVideoSizeMB = 100
    
    // MARK: - Cache
    static let predictionCacheDuration: TimeInterval = 300 // 5 minutes
    static let prayerTimesCacheDuration: TimeInterval = 3600 // 1 hour
    static let entitlementCacheDuration: TimeInterval = 300 // 5 minutes
    
    // MARK: - Rate Limits
    static let postCooldownSeconds = 300 // 5 minutes
    static let commentCooldownSeconds = 60 // 1 minute
    static let maxCommentsPerWindow = 10
    static let commentWindowSeconds = 900 // 15 minutes
    static let maxPointsPerDay = 50
    
    // MARK: - AI Limits
    static let aiInsightsLimitPerDay = 20
    static let aiQALimitPerDay = 50
    static let aiAnalysisLimitPerDay = 10
    
    // MARK: - Cycle Defaults
    static let defaultCycleLength = 28
    static let defaultPeriodLength = 5
    static let minCyclesForPrediction = 2
    static let maxCyclesForAverage = 6
    static let predictionWeights: [Double] = [0.30, 0.25, 0.20, 0.12, 0.08, 0.05]
    
    // MARK: - URLs
    static let privacyPolicyURL = URL(string: "https://myamanah.app/privacy")!
    static let termsOfServiceURL = URL(string: "https://myamanah.app/terms")!
    static let supportEmail = "support@myamanah.app"
    
    // MARK: - Deep Links
    enum DeepLink {
        static let scheme = "myamanah"
        static let host = "auth"
        static let callbackURL = URL(string: "\(scheme)://\(host)/callback")!
        static let dashboard = "\(scheme)://dashboard"
        static let track = "\(scheme)://track"
        static let athaan = "\(scheme)://athaan"
        static let spaces = "\(scheme)://spaces"
        static let settings = "\(scheme)://settings"
        static let subscribe = "\(scheme)://subscribe"
        
        static func space(_ id: String) -> String {
            "\(scheme)://spaces/\(id)"
        }
        
        static func post(_ spaceId: String, _ postId: String) -> String {
            "\(scheme)://spaces/\(spaceId)/post/\(postId)"
        }
    }
}

// MARK: - Build Configuration
enum BuildConfig {
    #if DEBUG
    static let environment: Environment = .development
    #else
    static let environment: Environment = .production
    #endif
    
    enum Environment {
        case development
        case staging
        case production
        
        var name: String {
            switch self {
            case .development: return "Development"
            case .staging: return "Staging"
            case .production: return "Production"
            }
        }
        
        var isDebug: Bool {
            self == .development
        }
    }
}
