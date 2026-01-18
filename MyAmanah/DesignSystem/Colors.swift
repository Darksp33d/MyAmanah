import SwiftUI

// MARK: - MyAmanah Color System
// Based on PRD Section 6.1

extension Color {
    // MARK: - Primary Palette
    static let backgroundPrimary = Color(hex: "EDE5D8")  // Warm cream background
    static let surfaceCard = Color(hex: "E5D7C4")        // Card/surface color
    static let surfaceContrast = Color(hex: "CFBB99")    // Darker contrast elements
    static let accentGreenLight = Color(hex: "889063")
    static let accentGreenDark = Color(hex: "354024")
    static let accentBrown = Color(hex: "4C3D19")
    
    // MARK: - Semantic Colors
    static let textPrimary = Color(hex: "2D2416")
    static let textSecondary = Color(hex: "6B5D4A")
    static let textTertiary = Color(hex: "9A8B76")
    static let textInverse = Color.white
    
    static let borderDefault = Color(hex: "D4C4AC")
    static let borderStrong = Color(hex: "A69578")
    
    static let statusError = Color(hex: "C45D4C")
    static let statusWarning = Color(hex: "D4A84C")
    static let statusSuccess = Color(hex: "889063")
    static let statusInfo = Color(hex: "5D7A99")
    
    // MARK: - Cycle Phase Colors
    static let cycleMenstrual = Color(hex: "C47D6D")
    static let cycleFollicular = Color(hex: "889063")
    static let cycleOvulation = Color(hex: "D4A84C")
    static let cycleLuteal = Color(hex: "7A6B5A")
}

// MARK: - Hex Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Gradient Definitions
extension LinearGradient {
    static let primaryGradient = LinearGradient(
        colors: [.accentGreenLight, .accentGreenDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardGradient = LinearGradient(
        colors: [.backgroundPrimary, .surfaceContrast.opacity(0.5)],
        startPoint: .top,
        endPoint: .bottom
    )
}
