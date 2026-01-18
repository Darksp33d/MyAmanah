import SwiftUI

// MARK: - Button Variants
enum MAButtonVariant {
    case primary
    case secondary
    case tertiary
    case destructive
    case ghost
}

// MARK: - Primary Button Component
struct MAButton: View {
    let title: String
    let variant: MAButtonVariant
    let size: MAButtonSize
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    init(
        _ title: String,
        variant: MAButtonVariant = .primary,
        size: MAButtonSize = .large,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.size = size
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if !isLoading && !isDisabled {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred(intensity: 0.5)
                action()
            }
        }) {
            HStack(spacing: MASpacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                        .scaleEffect(0.8)
                } else {
                    Text(title)
                        .font(size.font)
                        .fontWeight(.medium)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(MACornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: MACornerRadius.medium)
                    .stroke(borderColor, lineWidth: variant == .secondary ? 1.5 : 0)
            )
        }
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.4 : 1.0)
        .scaleEffect(isLoading ? 0.98 : 1.0)
        .animation(MAAnimation.quick, value: isLoading)
    }
    
    private var backgroundColor: Color {
        switch variant {
        case .primary:
            return .accentGreenDark
        case .secondary:
            return .clear
        case .tertiary:
            return .clear
        case .destructive:
            return .statusError
        case .ghost:
            return .clear
        }
    }
    
    private var textColor: Color {
        switch variant {
        case .primary:
            return .textInverse
        case .secondary:
            return .accentGreenDark
        case .tertiary:
            return .accentGreenLight
        case .destructive:
            return .textInverse
        case .ghost:
            return .textPrimary
        }
    }
    
    private var borderColor: Color {
        switch variant {
        case .secondary:
            return .accentGreenDark
        default:
            return .clear
        }
    }
}

// MARK: - Icon Button
struct MAIconButton: View {
    let icon: String
    let size: CGFloat
    let color: Color
    let action: () -> Void
    
    init(
        icon: String,
        size: CGFloat = 24,
        color: Color = .textPrimary,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred(intensity: 0.5)
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: size))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: MASpacing.lg) {
        MAButton("Primary Button", variant: .primary) {}
        MAButton("Secondary Button", variant: .secondary) {}
        MAButton("Tertiary Button", variant: .tertiary) {}
        MAButton("Destructive", variant: .destructive) {}
        MAButton("Loading...", isLoading: true) {}
        MAButton("Disabled", isDisabled: true) {}
    }
    .padding()
    .background(Color.backgroundPrimary)
}
