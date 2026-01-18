import SwiftUI

// MARK: - MyAmanah Typography System
// Based on PRD Section 6.2

enum MAFont {
    // MARK: - Display Styles
    static let displayLarge = Font.system(size: 34, weight: .semibold, design: .default)
    static let displayMedium = Font.system(size: 28, weight: .semibold, design: .default)
    static let displaySmall = Font.system(size: 22, weight: .semibold, design: .default)
    
    // MARK: - Title Styles
    static let titleLarge = Font.system(size: 20, weight: .semibold, design: .default)
    static let titleMedium = Font.system(size: 17, weight: .semibold, design: .default)
    static let titleSmall = Font.system(size: 15, weight: .semibold, design: .default)
    
    // MARK: - Body Styles
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .default)
    
    // MARK: - Label Styles
    static let labelLarge = Font.system(size: 15, weight: .medium, design: .default)
    static let labelMedium = Font.system(size: 13, weight: .medium, design: .default)
    static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)
    
    // MARK: - Monospace (for numbers/data)
    static let mono = Font.system(size: 15, weight: .regular, design: .monospaced)
    static let monoLarge = Font.system(size: 20, weight: .medium, design: .monospaced)
}

// MARK: - Text Style Modifiers
struct MATextStyle: ViewModifier {
    let font: Font
    let color: Color
    let lineSpacing: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(color)
            .lineSpacing(lineSpacing)
    }
}

extension View {
    func maTextStyle(_ font: Font, color: Color = .textPrimary, lineSpacing: CGFloat = 4) -> some View {
        modifier(MATextStyle(font: font, color: color, lineSpacing: lineSpacing))
    }
    
    // Convenience methods
    func displayLarge() -> some View {
        maTextStyle(MAFont.displayLarge)
    }
    
    func displayMedium() -> some View {
        maTextStyle(MAFont.displayMedium)
    }
    
    func displaySmall() -> some View {
        maTextStyle(MAFont.displaySmall)
    }
    
    func titleLarge() -> some View {
        maTextStyle(MAFont.titleLarge)
    }
    
    func titleMedium() -> some View {
        maTextStyle(MAFont.titleMedium)
    }
    
    func titleSmall() -> some View {
        maTextStyle(MAFont.titleSmall)
    }
    
    func bodyLarge() -> some View {
        maTextStyle(MAFont.bodyLarge)
    }
    
    func bodyMedium() -> some View {
        maTextStyle(MAFont.bodyMedium, color: .textSecondary)
    }
    
    func bodySmall() -> some View {
        maTextStyle(MAFont.bodySmall, color: .textSecondary)
    }
    
    func labelLarge() -> some View {
        maTextStyle(MAFont.labelLarge)
    }
    
    func labelMedium() -> some View {
        maTextStyle(MAFont.labelMedium)
    }
    
    func labelSmall() -> some View {
        maTextStyle(MAFont.labelSmall, color: .textTertiary)
    }
}
