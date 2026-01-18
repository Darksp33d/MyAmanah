import SwiftUI

struct SpacesView: View {
    @StateObject private var viewModel = SpacesViewModel()
    @State private var selectedTab = 0
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Tab Selector
                    Picker("", selection: $selectedTab) {
                        Text("My Spaces").tag(0)
                        Text("Discover").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, MASpacing.lg)
                    .padding(.vertical, MASpacing.md)
                    
                    if selectedTab == 0 {
                        mySpacesContent
                    } else {
                        discoverContent
                    }
                }
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Spaces")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search spaces")
        }
        .task {
            await viewModel.loadData()
        }
    }
    
    // MARK: - My Spaces Content
    private var mySpacesContent: some View {
        Group {
            if viewModel.joinedSpaces.isEmpty {
                MAEmptyState(
                    icon: "person.2.fill",
                    title: "Find Your Community",
                    description: "Discover spaces that match your interests",
                    actionTitle: "Explore Spaces"
                ) {
                    selectedTab = 1
                }
            } else {
                LazyVStack(spacing: MASpacing.md) {
                    ForEach(filteredJoinedSpaces) { space in
                        NavigationLink(destination: SpaceDetailView(space: space)) {
                            SpaceCard(space: space)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, MASpacing.lg)
                .padding(.bottom, MASpacing.md)
            }
        }
    }
    
    // MARK: - Discover Content
    private var discoverContent: some View {
        LazyVStack(alignment: .leading, spacing: MASpacing.xl) {
            ForEach(SpaceCategory.allCases, id: \.self) { category in
                categorySection(category)
            }
        }
        .padding(.horizontal, MASpacing.lg)
        .padding(.bottom, MASpacing.md)
    }
    
    private func categorySection(_ category: SpaceCategory) -> some View {
        let spaces = viewModel.spaces(for: category).filter {
            searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
        }
        
        return Group {
            if !spaces.isEmpty {
                VStack(alignment: .leading, spacing: MASpacing.md) {
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundColor(.accentGreenDark)
                        Text(category.displayName)
                            .font(MAFont.titleMedium)
                            .foregroundColor(.textPrimary)
                    }
                    
                    ForEach(spaces) { space in
                        NavigationLink(destination: SpaceDetailView(space: space)) {
                            SpaceCard(space: space)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    private var filteredJoinedSpaces: [Space] {
        if searchText.isEmpty {
            return viewModel.joinedSpaces
        }
        return viewModel.joinedSpaces.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
}

// MARK: - Space Card
struct SpaceCard: View {
    let space: Space
    
    var body: some View {
        MACard {
            HStack(spacing: MASpacing.md) {
                // Icon
                Circle()
                    .fill(Color.accentGreenLight.opacity(0.2))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: space.category.icon)
                            .font(.system(size: 20))
                            .foregroundColor(.accentGreenDark)
                    )
                
                VStack(alignment: .leading, spacing: MASpacing.xxs) {
                    HStack {
                        Text(space.name)
                            .font(MAFont.titleSmall)
                            .foregroundColor(.textPrimary)
                        
                        if space.isOfficial {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.accentGreenDark)
                        }
                    }
                    
                    Text(space.description ?? "")
                        .font(MAFont.bodySmall)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                    
                    HStack(spacing: MASpacing.md) {
                        Label("\(space.memberCount)", systemImage: "person.2")
                        Label("\(space.postCount)", systemImage: "text.bubble")
                    }
                    .font(MAFont.labelSmall)
                    .foregroundColor(.textTertiary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.textTertiary)
            }
        }
    }
}

// MARK: - Space Detail View
struct SpaceDetailView: View {
    let space: Space
    @StateObject private var viewModel = SpaceDetailViewModel()
    @State private var showCreatePost = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: MASpacing.md) {
                // Space Header
                spaceHeader
                
                // Posts
                if viewModel.posts.isEmpty {
                    MAEmptyState(
                        icon: "text.bubble",
                        title: "Be the First",
                        description: "Start a conversation in this space",
                        actionTitle: "Create Post"
                    ) {
                        showCreatePost = true
                    }
                    .padding(.top, MASpacing.xxl)
                } else {
                    ForEach(viewModel.posts) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            PostCard(post: post)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, MASpacing.lg)
            .padding(.vertical, MASpacing.md)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle(space.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showCreatePost = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(.accentGreenDark)
                }
            }
        }
        .sheet(isPresented: $showCreatePost) {
            CreatePostView(spaceId: space.id)
        }
        .task {
            await viewModel.loadPosts(for: space.id)
        }
    }
    
    private var spaceHeader: some View {
        MACard(variant: .elevated) {
            VStack(alignment: .leading, spacing: MASpacing.md) {
                HStack {
                    Circle()
                        .fill(Color.accentGreenLight.opacity(0.2))
                        .frame(width: 56, height: 56)
                        .overlay(
                            Image(systemName: space.category.icon)
                                .font(.system(size: 24))
                                .foregroundColor(.accentGreenDark)
                        )
                    
                    VStack(alignment: .leading) {
                        Text(space.name)
                            .font(MAFont.titleLarge)
                            .foregroundColor(.textPrimary)
                        
                        HStack(spacing: MASpacing.md) {
                            Label("\(space.memberCount) members", systemImage: "person.2")
                            Label("\(space.postCount) posts", systemImage: "text.bubble")
                        }
                        .font(MAFont.labelSmall)
                        .foregroundColor(.textSecondary)
                    }
                }
                
                if let description = space.description {
                    Text(description)
                        .font(MAFont.bodyMedium)
                        .foregroundColor(.textSecondary)
                }
                
                MAButton(viewModel.isJoined ? "Joined" : "Join Space", variant: viewModel.isJoined ? .secondary : .primary, size: .medium) {
                    Task { await viewModel.toggleJoin(space) }
                }
            }
        }
    }
}

#Preview {
    SpacesView()
}
