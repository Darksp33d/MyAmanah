import SwiftUI

// MARK: - Input Field Component
struct MAInputField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var errorMessage: String? = nil
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: MASpacing.xs) {
            Text(label)
                .font(MAFont.labelMedium)
                .foregroundColor(labelColor)
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .textContentType(textContentType)
                }
            }
            .font(MAFont.bodyLarge)
            .foregroundColor(.textPrimary)
            .padding(.horizontal, MASpacing.lg)
            .frame(height: 48)
            .background(Color.surfaceCard)
            .cornerRadius(MACornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: MACornerRadius.medium)
                    .stroke(borderColor, lineWidth: isFocused ? 2 : 1)
            )
            .focused($isFocused)
            .animation(MAAnimation.quick, value: isFocused)
            
            if let error = errorMessage {
                Text(error)
                    .font(MAFont.bodySmall)
                    .foregroundColor(.statusError)
            }
        }
    }
    
    private var labelColor: Color {
        if errorMessage != nil {
            return .statusError
        }
        return isFocused ? .accentGreenDark : .textSecondary
    }
    
    private var borderColor: Color {
        if errorMessage != nil {
            return .statusError
        }
        return isFocused ? .accentGreenDark : .borderDefault
    }
}

// MARK: - Text Area Component
struct MATextArea: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var maxLength: Int = 500
    var minHeight: CGFloat = 100
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: MASpacing.xs) {
            Text(label)
                .font(MAFont.labelMedium)
                .foregroundColor(isFocused ? .accentGreenDark : .textSecondary)
            
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(MAFont.bodyLarge)
                        .foregroundColor(.textTertiary)
                        .padding(.horizontal, MASpacing.lg)
                        .padding(.vertical, MASpacing.md)
                }
                
                TextEditor(text: $text)
                    .font(MAFont.bodyLarge)
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, MASpacing.sm)
                    .padding(.vertical, MASpacing.xs)
                    .scrollContentBackground(.hidden)
                    .focused($isFocused)
                    .onChange(of: text) { _, newValue in
                        if newValue.count > maxLength {
                            text = String(newValue.prefix(maxLength))
                        }
                    }
            }
            .frame(minHeight: minHeight)
            .background(Color.surfaceCard)
            .cornerRadius(MACornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: MACornerRadius.medium)
                    .stroke(isFocused ? Color.accentGreenDark : .borderDefault, lineWidth: isFocused ? 2 : 1)
            )
            
            HStack {
                Spacer()
                Text("\(text.count)/\(maxLength)")
                    .font(MAFont.labelSmall)
                    .foregroundColor(.textTertiary)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: MASpacing.lg) {
        MAInputField(
            label: "Email",
            placeholder: "Enter your email",
            text: .constant(""),
            keyboardType: .emailAddress,
            textContentType: .emailAddress
        )
        
        MAInputField(
            label: "Password",
            placeholder: "Enter password",
            text: .constant(""),
            isSecure: true
        )
        
        MAInputField(
            label: "With Error",
            placeholder: "Enter something",
            text: .constant("invalid"),
            errorMessage: "This field is invalid"
        )
        
        MATextArea(
            label: "Notes",
            placeholder: "Write your notes here...",
            text: .constant("")
        )
    }
    .padding()
    .background(Color.surfaceContrast)
}
