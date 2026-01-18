import SwiftUI

// MARK: - MyAmanah Spacing System
// Based on PRD Section 6.3

enum MASpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
}

// MARK: - Corner Radius
enum MACornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let extraLarge: CGFloat = 24
    static let full: CGFloat = 9999
}

// MARK: - Shadow Definitions
struct MAShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    static let card = MAShadow(
        color: .black.opacity(0.06),
        radius: 8,
        x: 0,
        y: 2
    )
    
    static let elevated = MAShadow(
        color: .black.opacity(0.1),
        radius: 12,
        x: 0,
        y: 4
    )
    
    static let subtle = MAShadow(
        color: .black.opacity(0.04),
        radius: 4,
        x: 0,
        y: 1
    )
}

// MARK: - Shadow View Modifier
extension View {
    func maShadow(_ shadow: MAShadow) -> some View {
        self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }
}

// MARK: - Animation Timing
enum MAAnimation {
    static let quick: Animation = .easeOut(duration: 0.15)
    static let standard: Animation = .easeInOut(duration: 0.25)
    static let emphasis: Animation = .spring(response: 0.35, dampingFraction: 0.8)
    static let gentle: Animation = .easeOut(duration: 0.4)
}

// MARK: - Button Sizes
enum MAButtonSize {
    case small
    case medium
    case large
    
    var height: CGFloat {
        switch self {
        case .small: return 32
        case .medium: return 44
        case .large: return 50
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small: return 8
        case .medium: return 12
        case .large: return 16
        }
    }
    
    var font: Font {
        switch self {
        case .small: return MAFont.labelSmall
        case .medium: return MAFont.labelMedium
        case .large: return MAFont.labelLarge
        }
    }
}
