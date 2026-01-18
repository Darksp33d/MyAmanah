import SwiftUI

// MARK: - Bottom Sheet Component
struct MABottomSheet<Content: View>: View {
    @Binding var isPresented: Bool
    let title: String?
    @ViewBuilder let content: Content
    
    @State private var offset: CGFloat = 0
    @State private var lastOffset: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if isPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismiss()
                    }
                    .transition(.opacity)
                
                VStack(spacing: 0) {
                    // Handle
                    Capsule()
                        .fill(Color.borderDefault)
                        .frame(width: 36, height: 4)
                        .padding(.top, MASpacing.md)
                        .padding(.bottom, MASpacing.sm)
                    
                    // Title
                    if let title = title {
                        Text(title)
                            .font(MAFont.titleMedium)
                            .foregroundColor(.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, MASpacing.xl)
                            .padding(.bottom, MASpacing.lg)
                    }
                    
                    // Content
                    content
                        .padding(.horizontal, MASpacing.xl)
                        .padding(.bottom, MASpacing.xxl)
                }
                .frame(maxWidth: .infinity)
                .background(Color.backgroundPrimary)
                .cornerRadius(MACornerRadius.extraLarge, corners: [.topLeft, .topRight])
                .offset(y: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let newOffset = lastOffset + value.translation.height
                            offset = max(0, newOffset)
                        }
                        .onEnded { value in
                            if value.translation.height > 100 {
                                dismiss()
                            } else {
                                withAnimation(MAAnimation.emphasis) {
                                    offset = 0
                                }
                            }
                            lastOffset = offset
                        }
                )
                .transition(.move(edge: .bottom))
            }
        }
        .animation(MAAnimation.emphasis, value: isPresented)
        .ignoresSafeArea()
    }
    
    private func dismiss() {
        withAnimation(MAAnimation.emphasis) {
            isPresented = false
            offset = 0
            lastOffset = 0
        }
    }
}

// MARK: - Corner Radius Extension for specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Sheet Modifier
extension View {
    func maSheet<Content: View>(
        isPresented: Binding<Bool>,
        title: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        ZStack {
            self
            MABottomSheet(isPresented: isPresented, title: title, content: content)
        }
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var showSheet = true
        
        var body: some View {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                Button("Show Sheet") {
                    showSheet = true
                }
            }
            .maSheet(isPresented: $showSheet, title: "Log Today") {
                VStack(spacing: MASpacing.lg) {
                    Text("Sheet content goes here")
                        .font(MAFont.bodyLarge)
                    
                    MAButton("Save") {
                        showSheet = false
                    }
                }
            }
        }
    }
    
    return PreviewWrapper()
}
