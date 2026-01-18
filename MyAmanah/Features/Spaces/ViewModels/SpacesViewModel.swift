import SwiftUI
import Combine

@MainActor
final class SpacesViewModel: ObservableObject {
    @Published var isLoading = false
    
    private let spacesService = SpacesService.shared
    private let supabase = SupabaseManager.shared
    
    var allSpaces: [Space] { spacesService.allSpaces }
    var joinedSpaces: [Space] { spacesService.joinedSpaces }
    
    func spaces(for category: SpaceCategory) -> [Space] {
        spacesService.spaces(for: category)
    }
    
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        await spacesService.fetchAllSpaces()
        if let userId = supabase.currentUser?.id {
            await spacesService.fetchJoinedSpaces(for: userId)
        }
    }
}

@MainActor
final class SpaceDetailViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isJoined = false
    @Published var isLoading = false
    
    private let spacesService = SpacesService.shared
    private let supabase = SupabaseManager.shared
    
    func loadPosts(for spaceId: UUID) async {
        isLoading = true
        defer { isLoading = false }
        
        await spacesService.fetchPosts(for: spaceId)
        posts = spacesService.currentSpacePosts
        
        if let space = spacesService.allSpaces.first(where: { $0.id == spaceId }) {
            isJoined = spacesService.isJoined(space)
        }
    }
    
    func toggleJoin(_ space: Space) async {
        guard let userId = supabase.currentUser?.id else { return }
        
        do {
            if isJoined {
                try await spacesService.leaveSpace(space, userId: userId)
            } else {
                try await spacesService.joinSpace(space, userId: userId)
            }
            isJoined.toggle()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}

@MainActor
final class PostDetailViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var isLoading = false
    @Published var newCommentText = ""
    
    private let spacesService = SpacesService.shared
    private let supabase = SupabaseManager.shared
    
    func loadComments(for postId: UUID) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            comments = try await spacesService.fetchComments(for: postId)
        } catch {
            print("Error loading comments: \(error)")
        }
    }
    
    func postComment(for postId: UUID) async {
        guard !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let userId = supabase.currentUser?.id else { return }
        
        do {
            let comment = try await spacesService.createComment(postId: postId, authorId: userId, body: newCommentText)
            comments.append(comment)
            newCommentText = ""
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
    
    func toggleUpvote(for post: Post) async {
        guard let userId = supabase.currentUser?.id else { return }
        
        do {
            if post.isUpvotedByCurrentUser {
                try await spacesService.removeUpvote(targetType: .post, targetId: post.id, userId: userId)
            } else {
                try await spacesService.upvote(targetType: .post, targetId: post.id, userId: userId)
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } catch {
            print("Error toggling upvote: \(error)")
        }
    }
}

@MainActor
final class CreatePostViewModel: ObservableObject {
    @Published var title = ""
    @Published var body = ""
    @Published var isLoading = false
    @Published var error: String?
    
    private let spacesService = SpacesService.shared
    private let supabase = SupabaseManager.shared
    
    var canSubmit: Bool {
        title.count >= 5 && title.count <= 200
    }
    
    func createPost(spaceId: UUID) async -> Bool {
        guard canSubmit, let userId = supabase.currentUser?.id else { return false }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            _ = try await spacesService.createPost(
                spaceId: spaceId,
                authorId: userId,
                title: title,
                body: body.isEmpty ? nil : body
            )
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            return true
        } catch {
            self.error = "Failed to create post. Please try again."
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return false
        }
    }
}
