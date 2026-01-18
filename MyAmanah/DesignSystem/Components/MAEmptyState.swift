import SwiftUI

// MARK: - Empty State Component
struct MAEmptyState: View {
    let icon: String
    let title: String
    let description: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        description: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: MASpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(.textTertiary)
                .frame(width: 128, height: 128)
            
            Text(title)
                .font(MAFont.titleMedium)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(MAFont.bodyMedium)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            if let actionTitle = actionTitle, let action = action {
                MAButton(actionTitle, variant: .primary, size: .medium, action: action)
                    .padding(.top, MASpacing.sm)
            }
        }
        .padding(MASpacing.xxl)
    }
}

// MARK: - Loading State
struct MALoadingState: View {
    let message: String
    
    init(_ message: String = "Loading...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: MASpacing.lg) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .accentGreenDark))
                .scaleEffect(1.5)
            
            Text(message)
                .font(MAFont.bodyMedium)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Skeleton Loader
struct MASkeletonLoader: View {
    let height: CGFloat
    
    @State private var isAnimating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: MACornerRadius.small)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.surfaceContrast,
                        Color.surfaceContrast.opacity(0.5),
                        Color.surfaceContrast
                    ]),
                    startPoint: isAnimating ? .trailing : .leading,
                    endPoint: isAnimating ? .leading : .trailing
                )
            )
            .frame(height: height)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Skeleton Card
struct MASkeletonCard: View {
    var body: some View {
        MACard {
            VStack(alignment: .leading, spacing: MASpacing.md) {
                HStack(spacing: MASpacing.md) {
                    MASkeletonLoader(height: 48)
                        .frame(width: 48)
                        .cornerRadius(24)
                    
                    VStack(alignment: .leading, spacing: MASpacing.xs) {
                        MASkeletonLoader(height: 16)
                            .frame(width: 120)
                        MASkeletonLoader(height: 12)
                            .frame(width: 80)
                    }
                }
                
                MASkeletonLoader(height: 14)
                MASkeletonLoader(height: 14)
                    .frame(width: 200)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: MASpacing.xxl) {
            MAEmptyState(
                icon: "calendar.badge.plus",
                title: "Start Your Journey",
                description: "Log your first period to begin tracking",
                actionTitle: "Log Period"
            ) {
                print("Action tapped")
            }
            
            MALoadingState("Loading your data...")
            
            MASkeletonCard()
            MASkeletonCard()
        }
        .padding()
    }
    .background(Color.backgroundPrimary)
}
