import Foundation

// MARK: - Space Model
struct Space: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String?
    let category: SpaceCategory
    let iconUrl: String?
    let isPrivate: Bool
    let isOfficial: Bool
    let createdBy: UUID?
    var memberCount: Int
    var postCount: Int
    let rules: [SpaceRule]
    let createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, category
        case iconUrl = "icon_url"
        case isPrivate = "is_private"
        case isOfficial = "is_official"
        case createdBy = "created_by"
        case memberCount = "member_count"
        case postCount = "post_count"
        case rules
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

// MARK: - Space Category
enum SpaceCategory: String, Codable, CaseIterable {
    case healthWellness = "health_wellness"
    case spirituality
    case relationships
    case careerEducation = "career_education"
    case lifestyle
    case support
    
    var displayName: String {
        switch self {
        case .healthWellness: return "Health & Wellness"
        case .spirituality: return "Spirituality & Faith"
        case .relationships: return "Relationships & Family"
        case .careerEducation: return "Career & Education"
        case .lifestyle: return "Lifestyle & Hobbies"
        case .support: return "Support & Advice"
        }
    }
    
    var icon: String {
        switch self {
        case .healthWellness: return "heart.fill"
        case .spirituality: return "moon.stars.fill"
        case .relationships: return "person.2.fill"
        case .careerEducation: return "briefcase.fill"
        case .lifestyle: return "sparkles"
        case .support: return "hands.clap.fill"
        }
    }
}

// MARK: - Space Rule
struct SpaceRule: Codable {
    let title: String
    let description: String
}

// MARK: - Space Member
struct SpaceMember: Codable, Identifiable {
    let id: UUID
    let spaceId: UUID
    let userId: UUID
    var role: SpaceMemberRole
    var points: Int
    let joinedAt: Date
    var mutedUntil: Date?
    var bannedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case spaceId = "space_id"
        case userId = "user_id"
        case role, points
        case joinedAt = "joined_at"
        case mutedUntil = "muted_until"
        case bannedAt = "banned_at"
    }
    
    var badge: UserBadge? {
        if points >= UserBadge.elder.minPoints {
            return .elder
        } else if points >= UserBadge.trusted.minPoints {
            return .trusted
        } else if points >= UserBadge.regular.minPoints {
            return .regular
        } else if points >= UserBadge.contributor.minPoints {
            return .contributor
        }
        return nil
    }
}

enum SpaceMemberRole: String, Codable {
    case member
    case moderator
    case admin
}

// MARK: - Post Model
struct Post: Codable, Identifiable {
    let id: UUID
    let spaceId: UUID
    let authorId: UUID
    let author: UserSummary?
    let title: String
    let body: String?
    let mediaUrls: [String]
    let mediaType: MediaType
    var upvoteCount: Int
    var commentCount: Int
    let isPinned: Bool
    var moderationStatus: ModerationStatus
    let createdAt: Date
    var updatedAt: Date
    var editedAt: Date?
    var deletedAt: Date?
    
    // Local state
    var isUpvotedByCurrentUser: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case spaceId = "space_id"
        case authorId = "author_id"
        case author
        case title, body
        case mediaUrls = "media_urls"
        case mediaType = "media_type"
        case upvoteCount = "upvote_count"
        case commentCount = "comment_count"
        case isPinned = "is_pinned"
        case moderationStatus = "moderation_status"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case editedAt = "edited_at"
        case deletedAt = "deleted_at"
    }
}

enum MediaType: String, Codable {
    case none
    case image
    case video
}

enum ModerationStatus: String, Codable {
    case pending
    case approved
    case rejected
    case removed
}

// MARK: - Comment Model
struct Comment: Codable, Identifiable {
    let id: UUID
    let postId: UUID
    let authorId: UUID
    let author: UserSummary?
    let parentId: UUID?
    let body: String
    var upvoteCount: Int
    let depth: Int
    var moderationStatus: ModerationStatus
    let createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    // Local state
    var isUpvotedByCurrentUser: Bool = false
    var replies: [Comment] = []
    
    enum CodingKeys: String, CodingKey {
        case id
        case postId = "post_id"
        case authorId = "author_id"
        case author
        case parentId = "parent_id"
        case body
        case upvoteCount = "upvote_count"
        case depth
        case moderationStatus = "moderation_status"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

// MARK: - Upvote
struct Upvote: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let targetType: UpvoteTargetType
    let targetId: UUID
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case targetType = "target_type"
        case targetId = "target_id"
        case createdAt = "created_at"
    }
}

enum UpvoteTargetType: String, Codable {
    case post
    case comment
}

// MARK: - Report
struct Report: Codable, Identifiable {
    let id: UUID
    let reporterId: UUID
    let targetType: ReportTargetType
    let targetId: UUID
    let reason: ReportReason
    let details: String?
    var status: ReportStatus
    let reviewedBy: UUID?
    let reviewedAt: Date?
    let actionTaken: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case reporterId = "reporter_id"
        case targetType = "target_type"
        case targetId = "target_id"
        case reason, details, status
        case reviewedBy = "reviewed_by"
        case reviewedAt = "reviewed_at"
        case actionTaken = "action_taken"
        case createdAt = "created_at"
    }
}

enum ReportTargetType: String, Codable {
    case post
    case comment
    case user
    case space
}

enum ReportReason: String, Codable, CaseIterable {
    case harassment
    case hateSpeech = "hate_speech"
    case inappropriateContent = "inappropriate_content"
    case spam
    case medicalMisinformation = "medical_misinformation"
    case privacyViolation = "privacy_violation"
    case impersonation
    case other
    
    var displayName: String {
        switch self {
        case .harassment: return "Harassment or Bullying"
        case .hateSpeech: return "Hate Speech or Discrimination"
        case .inappropriateContent: return "Inappropriate Content"
        case .spam: return "Spam or Self-Promotion"
        case .medicalMisinformation: return "Medical Misinformation"
        case .privacyViolation: return "Privacy Violation"
        case .impersonation: return "Impersonation"
        case .other: return "Other"
        }
    }
}

enum ReportStatus: String, Codable {
    case pending
    case reviewed
    case actioned
    case dismissed
}

// MARK: - Block
struct Block: Codable, Identifiable {
    let id: UUID
    let blockerId: UUID
    let blockedId: UUID
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case blockerId = "blocker_id"
        case blockedId = "blocked_id"
        case createdAt = "created_at"
    }
}
