import SwiftUI

struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SubscriptionViewModel()
    @State private var selectedPlan: SubscriptionPlan = .yearly
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: MASpacing.xl) {
                    // Header
                    VStack(spacing: MASpacing.md) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.accentGreenDark)
                        
                        Text("Unlock Full Access")
                            .font(MAFont.displayMedium)
                            .foregroundColor(.textPrimary)
                        
                        Text("Get the most out of MyAmanah")
                            .font(MAFont.bodyMedium)
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.top, MASpacing.xxl)
                    
                    // Features
                    VStack(alignment: .leading, spacing: MASpacing.md) {
                        featureRow(icon: "chart.line.uptrend.xyaxis", text: "Deep cycle insights & AI analysis")
                        featureRow(icon: "person.2.fill", text: "Join the community discussion")
                        featureRow(icon: "plus.circle.fill", text: "Create & moderate your own spaces")
                        featureRow(icon: "sparkles", text: "Ad-free experience")
                    }
                    .padding(.horizontal, MASpacing.lg)
                    
                    // Plan Selection
                    VStack(spacing: MASpacing.md) {
                        planCard(.monthly, isSelected: selectedPlan == .monthly)
                        planCard(.yearly, isSelected: selectedPlan == .yearly)
                    }
                    .padding(.horizontal, MASpacing.lg)
                    
                    // CTA
                    VStack(spacing: MASpacing.md) {
                        MAButton("Start Free Trial — 7 days free", isLoading: viewModel.isLoading) {
                            Task { await viewModel.purchase(selectedPlan) }
                        }
                        
                        Text("Cancel anytime. No commitment.")
                            .font(MAFont.labelSmall)
                            .foregroundColor(.textTertiary)
                    }
                    .padding(.horizontal, MASpacing.lg)
                    
                    // Footer
                    HStack(spacing: MASpacing.lg) {
                        Button("Restore Purchases") {
                            Task { await viewModel.restorePurchases() }
                        }
                        Text("•")
                        Link("Terms", destination: AppConfig.termsOfServiceURL)
                        Text("•")
                        Link("Privacy", destination: AppConfig.privacyPolicyURL)
                    }
                    .font(MAFont.labelSmall)
                    .foregroundColor(.textTertiary)
                    .padding(.bottom, MASpacing.xxl)
                }
            }
            .background(Color.backgroundPrimary)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.textTertiary)
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: MASpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.accentGreenDark)
                .frame(width: 32)
            
            Text(text)
                .font(MAFont.bodyLarge)
                .foregroundColor(.textPrimary)
            
            Spacer()
        }
    }
    
    private func planCard(_ plan: SubscriptionPlan, isSelected: Bool) -> some View {
        Button(action: { selectedPlan = plan }) {
            HStack {
                VStack(alignment: .leading, spacing: MASpacing.xxs) {
                    Text(plan.name)
                        .font(MAFont.titleSmall)
                        .foregroundColor(.textPrimary)
                    Text(plan.priceDescription)
                        .font(MAFont.bodySmall)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                if plan == .yearly {
                    MAStatusBadge(status: "SAVE 40%", color: .accentGreenDark)
                }
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .accentGreenDark : .borderDefault)
            }
            .padding(MASpacing.lg)
            .background(isSelected ? Color.accentGreenDark.opacity(0.1) : Color.surfaceContrast.opacity(0.3))
            .cornerRadius(MACornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: MACornerRadius.medium)
                    .stroke(isSelected ? Color.accentGreenDark : .clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Subscription Plan
enum SubscriptionPlan {
    case monthly
    case yearly
    
    var name: String {
        switch self {
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
    
    var priceDescription: String {
        switch self {
        case .monthly: return "$6.99/month"
        case .yearly: return "$49.99/year"
        }
    }
    
    var productId: String {
        switch self {
        case .monthly: return AppConfig.monthlyProductId
        case .yearly: return AppConfig.yearlyProductId
        }
    }
}

// MARK: - Subscription ViewModel
@MainActor
final class SubscriptionViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    func purchase(_ plan: SubscriptionPlan) async {
        isLoading = true
        defer { isLoading = false }
        
        // StoreKit 2 purchase implementation would go here
        // For now, simulate a delay
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Show success or handle actual purchase
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        
        // StoreKit 2 restore implementation would go here
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }
}

#Preview {
    SubscriptionView()
}
