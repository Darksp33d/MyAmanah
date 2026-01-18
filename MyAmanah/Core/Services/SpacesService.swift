import Foundation
import Combine
internal import PostgREST

// MARK: - Update DTO
struct SoftDeleteUpdate: Codable {
    let deletedAt: String
    
    enum CodingKeys: String, CodingKey {
        case deletedAt = "deleted_at"
    }
}

// MARK: - Spaces Service
@MainActor
final class SpacesService: ObservableObject {
    static let shared = SpacesService()
    
    private let supabase = SupabaseManager.shared
    
    @Published private(set) var allSpaces: [Space] = []
    @Published private(set) var joinedSpaces: [Space] = []
    @Published private(set) var currentSpacePosts: [Post] = []
    @Published private(set) var isLoading = false
    @Published var error: Error?
    
    private init() {}
    
    // MARK: - Fetch Spaces
    func fetchAllSpaces() async {
        isLoading = true
        defer { isLoading = false }
        do {
            allSpaces = try await supabase.fetch(from: "spaces") { $0.is("deleted_at", value: nil) }
        } catch { self.error = error }
    }
    
    func fetchJoinedSpaces(for userId: UUID) async {
        do {
            let memberships: [SpaceMember] = try await supabase.fetch(from: "space_members") { $0.eq("user_id", value: userId.uuidString).is("banned_at", value: nil) }
            let spaceIds = memberships.map { $0.spaceId.uuidString }
            if !spaceIds.isEmpty {
                joinedSpaces = try await supabase.fetch(from: "spaces") { $0.in("id", values: spaceIds) }
            }
        } catch { self.error = error }
    }
    
    func spaces(for category: SpaceCategory) -> [Space] {
        allSpaces.filter { $0.category == category }
    }
    
    // MARK: - Join/Leave Space
    func joinSpace(_ space: Space, userId: UUID) async throws {
        let member = SpaceMember(id: UUID(), spaceId: space.id, userId: userId, role: .member, points: 0, joinedAt: Date(), mutedUntil: nil, bannedAt: nil)
        try await supabase.insert(into: "space_members", value: member)
        if !joinedSpaces.contains(where: { $0.id == space.id }) { joinedSpaces.append(space) }
    }
    
    func leaveSpace(_ space: Space, userId: UUID) async throws {
        try await supabase.delete(from: "space_members") { $0.eq("space_id", value: space.id.uuidString).eq("user_id", value: userId.uuidString) }
        joinedSpaces.removeAll { $0.id == space.id }
    }
    
    func isJoined(_ space: Space) -> Bool {
        joinedSpaces.contains { $0.id == space.id }
    }
    
    // MARK: - Posts
    func fetchPosts(for spaceId: UUID) async {
        isLoading = true
        defer { isLoading = false }
        do {
            currentSpacePosts = try await supabase.fetch(from: "posts") { $0.eq("space_id", value: spaceId.uuidString).eq("moderation_status", value: "approved").is("deleted_at", value: nil) }
        } catch { self.error = error }
    }
    
    func createPost(spaceId: UUID, authorId: UUID, title: String, body: String?, mediaUrls: [String] = [], mediaType: MediaType = .none) async throws -> Post {
        let post = Post(id: UUID(), spaceId: spaceId, authorId: authorId, author: nil, title: title, body: body, mediaUrls: mediaUrls, mediaType: mediaType, upvoteCount: 0, commentCount: 0, isPinned: false, moderationStatus: .approved, createdAt: Date(), updatedAt: Date(), editedAt: nil, deletedAt: nil)
        try await supabase.insert(into: "posts", value: post)
        currentSpacePosts.insert(post, at: 0)
        return post
    }
    
    func deletePost(_ post: Post) async throws {
        let update = SoftDeleteUpdate(deletedAt: ISO8601DateFormatter().string(from: Date()))
        try await supabase.update(table: "posts", value: update) { $0.eq("id", value: post.id.uuidString) }
        currentSpacePosts.removeAll { $0.id == post.id }
    }
    
    // MARK: - Comments
    func fetchComments(for postId: UUID) async throws -> [Comment] {
        try await supabase.fetch(from: "comments") { builder in
            builder.eq("post_id", value: postId.uuidString)
                .eq("moderation_status", value: "approved").is("deleted_at", value: nil)
        }
    }
    
    func createComment(postId: UUID, authorId: UUID, body: String, parentId: UUID? = nil, depth: Int = 0) async throws -> Comment {
        let comment = Comment(id: UUID(), postId: postId, authorId: authorId, author: nil, parentId: parentId, body: body, upvoteCount: 0, depth: depth, moderationStatus: .approved, createdAt: Date(), updatedAt: Date(), deletedAt: nil)
        try await supabase.insert(into: "comments", value: comment)
        return comment
    }
    
    // MARK: - Upvotes
    func upvote(targetType: UpvoteTargetType, targetId: UUID, userId: UUID) async throws {
        let upvote = Upvote(id: UUID(), userId: userId, targetType: targetType, targetId: targetId, createdAt: Date())
        try await supabase.insert(into: "upvotes", value: upvote)
        if targetType == .post, let idx = currentSpacePosts.firstIndex(where: { $0.id == targetId }) {
            currentSpacePosts[idx].upvoteCount += 1
            currentSpacePosts[idx].isUpvotedByCurrentUser = true
        }
    }
    
    func removeUpvote(targetType: UpvoteTargetType, targetId: UUID, userId: UUID) async throws {
        try await supabase.delete(from: "upvotes") { $0.eq("user_id", value: userId.uuidString).eq("target_type", value: targetType.rawValue).eq("target_id", value: targetId.uuidString) }
        if targetType == .post, let idx = currentSpacePosts.firstIndex(where: { $0.id == targetId }) {
            currentSpacePosts[idx].upvoteCount = max(0, currentSpacePosts[idx].upvoteCount - 1)
            currentSpacePosts[idx].isUpvotedByCurrentUser = false
        }
    }
    
    // MARK: - Reports
    func reportContent(reporterId: UUID, targetType: ReportTargetType, targetId: UUID, reason: ReportReason, details: String?) async throws {
        let report = Report(id: UUID(), reporterId: reporterId, targetType: targetType, targetId: targetId, reason: reason, details: details, status: .pending, reviewedBy: nil, reviewedAt: nil, actionTaken: nil, createdAt: Date())
        try await supabase.insert(into: "reports", value: report)
    }
}

