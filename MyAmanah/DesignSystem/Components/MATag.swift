import SwiftUI

// MARK: - Tag Component (for symptoms, moods, badges)
struct MATag: View {
    let text: String
    let isSelected: Bool
    let color: Color
    let action: (() -> Void)?
    
    init(
        _ text: String,
        isSelected: Bool = false,
        color: Color = .surfaceContrast,
        action: (() -> Void)? = nil
    ) {
        self.text = text
        self.isSelected = isSelected
        self.color = color
        self.action = action
    }
    
    var body: some View {
        if let action = action {
            Button(action: {
                let generator = UISelectionFeedbackGenerator()
                generator.selectionChanged()
                action()
            }) {
                tagContent
            }
        } else {
            tagContent
        }
    }
    
    private var tagContent: some View {
        Text(text)
            .font(MAFont.labelMedium)
            .foregroundColor(isSelected ? .textInverse : .textPrimary)
            .padding(.horizontal, MASpacing.md)
            .padding(.vertical, MASpacing.sm)
            .background(isSelected ? color : color.opacity(0.3))
            .cornerRadius(MACornerRadius.small)
            .overlay(
                RoundedRectangle(cornerRadius: MACornerRadius.small)
                    .stroke(isSelected ? color : .clear, lineWidth: 1)
            )
            .animation(MAAnimation.quick, value: isSelected)
    }
}

// MARK: - Badge Component (for user badges in Spaces)
struct MABadge: View {
    let badge: UserBadge
    
    var body: some View {
        Text(badge.rawValue.capitalized)
            .font(MAFont.labelSmall)
            .foregroundColor(.textInverse)
            .padding(.horizontal, MASpacing.sm)
            .padding(.vertical, MASpacing.xs)
            .background(badge.color)
            .cornerRadius(MACornerRadius.full)
    }
}

enum UserBadge: String, Codable {
    case contributor
    case regular
    case trusted
    case elder
    
    var color: Color {
        switch self {
        case .contributor: return Color(hex: "CD7F32") // Bronze
        case .regular: return Color(hex: "C0C0C0") // Silver
        case .trusted: return Color(hex: "FFD700") // Gold
        case .elder: return Color(hex: "50C878") // Emerald
        }
    }
    
    var minPoints: Int {
        switch self {
        case .contributor: return 50
        case .regular: return 200
        case .trusted: return 500
        case .elder: return 1000
        }
    }
}

// MARK: - Status Badge
struct MAStatusBadge: View {
    let status: String
    let color: Color
    
    var body: some View {
        Text(status)
            .font(MAFont.labelSmall)
            .foregroundColor(.textInverse)
            .padding(.horizontal, MASpacing.sm)
            .padding(.vertical, MASpacing.xxs)
            .background(color)
            .cornerRadius(MACornerRadius.full)
    }
}

// MARK: - Flow Layout for Tags
struct FlowLayout: Layout {
    var spacing: CGFloat = MASpacing.sm
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return CGSize(width: proposal.width ?? 0, height: result.height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var positions: [CGPoint] = []
        var height: CGFloat = 0
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > width && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }
            
            height = y + rowHeight
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: MASpacing.lg) {
        HStack(spacing: MASpacing.sm) {
            MATag("Cramps", isSelected: true, color: .accentGreenDark)
            MATag("Headache", isSelected: false, color: .surfaceContrast)
            MATag("Fatigue", isSelected: true, color: .accentGreenDark)
        }
        
        HStack(spacing: MASpacing.sm) {
            MABadge(badge: .contributor)
            MABadge(badge: .regular)
            MABadge(badge: .trusted)
            MABadge(badge: .elder)
        }
        
        HStack(spacing: MASpacing.sm) {
            MAStatusBadge(status: "Premium", color: .accentGreenDark)
            MAStatusBadge(status: "New", color: .statusInfo)
        }
    }
    .padding()
    .background(Color.backgroundPrimary)
}
