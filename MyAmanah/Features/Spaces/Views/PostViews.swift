import SwiftUI

// MARK: - Post Card
struct PostCard: View {
    let post: Post
    
    var body: some View {
        MACard {
            VStack(alignment: .leading, spacing: MASpacing.md) {
                // Author Row
                HStack(spacing: MASpacing.sm) {
                    Circle()
                        .fill(Color.surfaceContrast)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Text(String(post.author?.displayName.prefix(1) ?? "?"))
                                .font(MAFont.labelMedium)
                                .foregroundColor(.textPrimary)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: MASpacing.xs) {
                            Text(post.author?.displayName ?? "Anonymous")
                                .font(MAFont.labelMedium)
                                .foregroundColor(.textPrimary)
                            
                            if let badge = post.author?.badge {
                                MABadge(badge: badge)
                            }
                        }
                        
                        Text(post.createdAt.timeAgo)
                            .font(MAFont.labelSmall)
                            .foregroundColor(.textTertiary)
                    }
                    
                    Spacer()
                }
                
                // Title
                Text(post.title)
                    .font(MAFont.titleSmall)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                
                // Body Preview
                if let body = post.body, !body.isEmpty {
                    Text(body)
                        .font(MAFont.bodyMedium)
                        .foregroundColor(.textSecondary)
                        .lineLimit(3)
                }
                
                // Actions
                HStack(spacing: MASpacing.lg) {
                    Label("\(post.upvoteCount)", systemImage: post.isUpvotedByCurrentUser ? "arrow.up.circle.fill" : "arrow.up.circle")
                        .foregroundColor(post.isUpvotedByCurrentUser ? .accentGreenDark : .textSecondary)
                    
                    Label("\(post.commentCount)", systemImage: "bubble.right")
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                }
                .font(MAFont.labelMedium)
            }
        }
    }
}

// MARK: - Post Detail View
struct PostDetailView: View {
    let post: Post
    @StateObject private var viewModel = PostDetailViewModel()
    @FocusState private var isCommentFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: MASpacing.lg) {
                    // Post Content
                    postContent
                    
                    Divider()
                    
                    // Comments
                    commentsSection
                }
                .padding(.horizontal, MASpacing.lg)
                .padding(.vertical, MASpacing.md)
            }
            
            // Comment Input
            commentInput
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadComments(for: post.id)
        }
    }
    
    private var postContent: some View {
        VStack(alignment: .leading, spacing: MASpacing.md) {
            // Author
            HStack(spacing: MASpacing.sm) {
                Circle()
                    .fill(Color.surfaceContrast)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(String(post.author?.displayName.prefix(1) ?? "?"))
                            .font(MAFont.titleSmall)
                            .foregroundColor(.textPrimary)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(post.author?.displayName ?? "Anonymous")
                            .font(MAFont.titleSmall)
                            .foregroundColor(.textPrimary)
                        if let badge = post.author?.badge {
                            MABadge(badge: badge)
                        }
                    }
                    Text(post.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(MAFont.labelSmall)
                        .foregroundColor(.textTertiary)
                }
                
                Spacer()
                
                Menu {
                    Button(role: .destructive, action: {}) {
                        Label("Report", systemImage: "flag")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.textSecondary)
                        .frame(width: 44, height: 44)
                }
            }
            
            // Title
            Text(post.title)
                .font(MAFont.titleLarge)
                .foregroundColor(.textPrimary)
            
            // Body
            if let body = post.body {
                Text(body)
                    .font(MAFont.bodyLarge)
                    .foregroundColor(.textPrimary)
            }
            
            // Actions
            HStack(spacing: MASpacing.xl) {
                Button(action: { Task { await viewModel.toggleUpvote(for: post) } }) {
                    Label("\(post.upvoteCount)", systemImage: post.isUpvotedByCurrentUser ? "arrow.up.circle.fill" : "arrow.up.circle")
                        .foregroundColor(post.isUpvotedByCurrentUser ? .accentGreenDark : .textSecondary)
                }
                
                Label("\(viewModel.comments.count)", systemImage: "bubble.right")
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.textSecondary)
                }
            }
            .font(MAFont.labelLarge)
        }
    }
    
    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: MASpacing.md) {
            Text("Comments")
                .font(MAFont.titleMedium)
                .foregroundColor(.textPrimary)
            
            if viewModel.comments.isEmpty {
                Text("No comments yet. Be the first!")
                    .font(MAFont.bodyMedium)
                    .foregroundColor(.textTertiary)
                    .padding(.vertical, MASpacing.lg)
            } else {
                ForEach(viewModel.comments) { comment in
                    CommentRow(comment: comment)
                }
            }
        }
    }
    
    private var commentInput: some View {
        HStack(spacing: MASpacing.sm) {
            TextField("Add a comment...", text: $viewModel.newCommentText)
                .font(MAFont.bodyMedium)
                .padding(.horizontal, MASpacing.md)
                .padding(.vertical, MASpacing.sm)
                .background(Color.surfaceContrast)
                .cornerRadius(MACornerRadius.large)
                .focused($isCommentFocused)
            
            Button(action: { Task { await viewModel.postComment(for: post.id) } }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(viewModel.newCommentText.isEmpty ? .textTertiary : .accentGreenDark)
            }
            .disabled(viewModel.newCommentText.isEmpty)
        }
        .padding(.horizontal, MASpacing.lg)
        .padding(.vertical, MASpacing.md)
        .background(Color.backgroundPrimary)
    }
}

// MARK: - Comment Row
struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: MASpacing.sm) {
            Circle()
                .fill(Color.surfaceContrast)
                .frame(width: 32, height: 32)
                .overlay(
                    Text(String(comment.author?.displayName.prefix(1) ?? "?"))
                        .font(MAFont.labelSmall)
                        .foregroundColor(.textPrimary)
                )
            
            VStack(alignment: .leading, spacing: MASpacing.xs) {
                HStack {
                    Text(comment.author?.displayName ?? "Anonymous")
                        .font(MAFont.labelMedium)
                        .foregroundColor(.textPrimary)
                    
                    Text(comment.createdAt.timeAgo)
                        .font(MAFont.labelSmall)
                        .foregroundColor(.textTertiary)
                }
                
                Text(comment.body)
                    .font(MAFont.bodyMedium)
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: MASpacing.md) {
                    Button(action: {}) {
                        Label("\(comment.upvoteCount)", systemImage: "arrow.up")
                            .font(MAFont.labelSmall)
                            .foregroundColor(.textSecondary)
                    }
                    
                    Button(action: {}) {
                        Text("Reply")
                            .font(MAFont.labelSmall)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
        }
        .padding(.leading, CGFloat(comment.depth * 24))
    }
}

// MARK: - Create Post View
struct CreatePostView: View {
    let spaceId: UUID
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreatePostViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: MASpacing.lg) {
                MAInputField(
                    label: "Title",
                    placeholder: "What's on your mind?",
                    text: $viewModel.title
                )
                
                MATextArea(
                    label: "Details (optional)",
                    placeholder: "Share more details...",
                    text: $viewModel.body,
                    maxLength: 5000
                )
                
                Spacer()
                
                if let error = viewModel.error {
                    Text(error)
                        .font(MAFont.bodySmall)
                        .foregroundColor(.statusError)
                }
                
                MAButton("Post", isLoading: viewModel.isLoading, isDisabled: !viewModel.canSubmit) {
                    Task {
                        if await viewModel.createPost(spaceId: spaceId) {
                            dismiss()
                        }
                    }
                }
            }
            .padding(MASpacing.lg)
            .background(Color.backgroundPrimary)
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Date Extension
extension Date {
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

#Preview {
    PostCard(post: Post(
        id: UUID(),
        spaceId: UUID(),
        authorId: UUID(),
        author: UserSummary(id: UUID(), displayName: "Sarah", avatarUrl: nil, badge: .trusted),
        title: "Tips for managing cramps during Ramadan?",
        body: "Salam sisters! I'm looking for advice on managing period cramps while fasting. Any natural remedies that have worked for you?",
        mediaUrls: [],
        mediaType: .none,
        upvoteCount: 24,
        commentCount: 12,
        isPinned: false,
        moderationStatus: .approved,
        createdAt: Date().addingTimeInterval(-3600),
        updatedAt: Date(),
        editedAt: nil,
        deletedAt: nil
    ))
    .padding()
    .background(Color.backgroundPrimary)
}
