import SwiftUI

// MARK: - Card Variants
enum MACardVariant {
    case `default`
    case elevated
    case interactive
    case featured
}

// MARK: - Card Component
struct MACard<Content: View>: View {
    let variant: MACardVariant
    let action: (() -> Void)?
    @ViewBuilder let content: Content
    
    init(
        variant: MACardVariant = .default,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.variant = variant
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Group {
            if let action = action {
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred(intensity: 0.3)
                    action()
                }) {
                    cardContent
                }
                .buttonStyle(CardButtonStyle())
            } else {
                cardContent
            }
        }
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(MASpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
        .cornerRadius(MACornerRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: MACornerRadius.large)
                .stroke(borderColor, lineWidth: 1)
        )
        .maShadow(shadow)
    }
    
    private var backgroundColor: Color {
        switch variant {
        case .default, .interactive:
            return .surfaceCard
        case .elevated:
            return .surfaceContrast
        case .featured:
            return .surfaceCard
        }
    }
    
    private var borderColor: Color {
        switch variant {
        case .featured:
            return .accentGreenLight.opacity(0.5)
        default:
            return .borderDefault
        }
    }
    
    private var shadow: MAShadow {
        switch variant {
        case .elevated:
            return .elevated
        default:
            return .card
        }
    }
}

// MARK: - Card Button Style
struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(MAAnimation.quick, value: configuration.isPressed)
    }
}

// MARK: - Status Card (for Dashboard)
struct MAStatusCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    let accentColor: Color
    let action: (() -> Void)?
    
    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String,
        accentColor: Color = .accentGreenDark,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.accentColor = accentColor
        self.action = action
    }
    
    var body: some View {
        MACard(variant: .interactive, action: action) {
            HStack(spacing: MASpacing.lg) {
                Circle()
                    .fill(accentColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundColor(accentColor)
                    )
                
                VStack(alignment: .leading, spacing: MASpacing.xs) {
                    Text(title)
                        .font(MAFont.bodySmall)
                        .foregroundColor(.textSecondary)
                    
                    Text(value)
                        .font(MAFont.titleLarge)
                        .foregroundColor(.textPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(MAFont.bodySmall)
                            .foregroundColor(.textTertiary)
                    }
                }
                
                Spacer()
                
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.textTertiary)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: MASpacing.lg) {
            MACard {
                VStack(alignment: .leading, spacing: MASpacing.sm) {
                    Text("Default Card")
                        .font(MAFont.titleMedium)
                    Text("This is a default card with some content.")
                        .font(MAFont.bodyMedium)
                        .foregroundColor(.textSecondary)
                }
            }
            
            MACard(variant: .elevated) {
                Text("Elevated Card")
                    .font(MAFont.titleMedium)
            }
            
            MAStatusCard(
                title: "Cycle Day",
                value: "Day 14",
                subtitle: "Ovulation phase",
                icon: "circle.circle",
                accentColor: .cycleOvulation
            ) {
                print("Tapped")
            }
        }
        .padding()
    }
    .background(Color.backgroundPrimary)
}
