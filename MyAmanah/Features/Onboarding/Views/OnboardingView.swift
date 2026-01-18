import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var isOnboardingComplete: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                switch viewModel.currentStep {
                case .welcome:
                    welcomeView
                case .valueProps:
                    valuePropsView
                case .auth:
                    authView
                case .profile:
                    profileSetupView
                case .permissions:
                    permissionsView
                case .premium:
                    premiumOfferView
                }
            }
        }
    }
    
    // MARK: - Welcome
    private var welcomeView: some View {
        VStack(spacing: MASpacing.xxl) {
            Spacer()
            
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentGreenDark)
            
            VStack(spacing: MASpacing.md) {
                Text("MyAmanah")
                    .font(MAFont.displayLarge)
                    .foregroundColor(.textPrimary)
                
                Text("Your trusted companion for health & faith")
                    .font(MAFont.bodyLarge)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            MAButton("Get Started") {
                viewModel.nextStep()
            }
            .padding(.horizontal, MASpacing.xl)
            .padding(.bottom, MASpacing.xxl)
        }
    }
    
    // MARK: - Value Props
    private var valuePropsView: some View {
        TabView(selection: $viewModel.currentValuePropPage) {
            valuePropsPage(
                icon: "heart.text.square.fill",
                title: "Track Your Cycle",
                description: "Private, secure cycle tracking with intelligent predictions tailored to you.",
                page: 0
            )
            
            valuePropsPage(
                icon: "moon.stars.fill",
                title: "Stay Connected to Faith",
                description: "Accurate prayer times, daily Islamic wisdom, and spiritual reminders.",
                page: 1
            )
            
            valuePropsPage(
                icon: "person.2.fill",
                title: "Join a Safe Community",
                description: "Connect with other Muslim women in moderated, supportive spaces.",
                page: 2
            )
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .overlay(alignment: .bottom) {
            MAButton("Continue") {
                if viewModel.currentValuePropPage < 2 {
                    withAnimation { viewModel.currentValuePropPage += 1 }
                } else {
                    viewModel.nextStep()
                }
            }
            .padding(.horizontal, MASpacing.xl)
            .padding(.bottom, MASpacing.xxl)
        }
    }
    
    private func valuePropsPage(icon: String, title: String, description: String, page: Int) -> some View {
        VStack(spacing: MASpacing.xl) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 100))
                .foregroundColor(.accentGreenDark)
            
            VStack(spacing: MASpacing.md) {
                Text(title)
                    .font(MAFont.displayMedium)
                    .foregroundColor(.textPrimary)
                
                Text(description)
                    .font(MAFont.bodyLarge)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, MASpacing.xl)
            }
            
            Spacer()
            Spacer()
        }
        .tag(page)
    }
    
    // MARK: - Auth
    private var authView: some View {
        VStack(spacing: MASpacing.xl) {
            Spacer()
            
            VStack(spacing: MASpacing.md) {
                Text("Create Account")
                    .font(MAFont.displayMedium)
                    .foregroundColor(.textPrimary)
                
                Text("Sign up to sync your data securely")
                    .font(MAFont.bodyMedium)
                    .foregroundColor(.textSecondary)
            }
            
            VStack(spacing: MASpacing.lg) {
                MAInputField(
                    label: "Email",
                    placeholder: "your@email.com",
                    text: $viewModel.email,
                    keyboardType: .emailAddress,
                    textContentType: .emailAddress
                )
                
                MAInputField(
                    label: "Password",
                    placeholder: "Create a password",
                    text: $viewModel.password,
                    isSecure: true
                )
                
                if let error = viewModel.authError {
                    Text(error)
                        .font(MAFont.bodySmall)
                        .foregroundColor(.statusError)
                }
            }
            .padding(.horizontal, MASpacing.xl)
            
            VStack(spacing: MASpacing.md) {
                MAButton("Create Account", isLoading: viewModel.isLoading) {
                    Task { await viewModel.signUp() }
                }
                
                Text("or")
                    .font(MAFont.labelMedium)
                    .foregroundColor(.textTertiary)
                
                MAButton("Continue with Apple", variant: .secondary) {
                    Task { await viewModel.signInWithApple() }
                }
                
                Button("Already have an account? Sign In") {
                    viewModel.showSignIn = true
                }
                .font(MAFont.labelMedium)
                .foregroundColor(.accentGreenDark)
                
                Button("Skip for now") {
                    viewModel.skipAuth()
                }
                .font(MAFont.labelSmall)
                .foregroundColor(.textTertiary)
            }
            .padding(.horizontal, MASpacing.xl)
            
            Spacer()
        }
        .sheet(isPresented: $viewModel.showSignIn) {
            SignInView(onComplete: { viewModel.nextStep() })
        }
    }
    
    // MARK: - Profile Setup
    private var profileSetupView: some View {
        VStack(spacing: MASpacing.xl) {
            Spacer()
            
            VStack(spacing: MASpacing.md) {
                Text("Set Up Your Profile")
                    .font(MAFont.displayMedium)
                    .foregroundColor(.textPrimary)
                
                Text("Help us personalize your experience")
                    .font(MAFont.bodyMedium)
                    .foregroundColor(.textSecondary)
            }
            
            VStack(spacing: MASpacing.lg) {
                MAInputField(
                    label: "Display Name",
                    placeholder: "How should we call you?",
                    text: $viewModel.displayName
                )
                
                VStack(alignment: .leading, spacing: MASpacing.sm) {
                    Text("Average Cycle Length (optional)")
                        .font(MAFont.labelMedium)
                        .foregroundColor(.textSecondary)
                    
                    Stepper("\(viewModel.cycleLength) days", value: $viewModel.cycleLength, in: 21...35)
                        .padding(MASpacing.md)
                        .background(Color.surfaceContrast.opacity(0.3))
                        .cornerRadius(MACornerRadius.medium)
                }
            }
            .padding(.horizontal, MASpacing.xl)
            
            Spacer()
            
            VStack(spacing: MASpacing.md) {
                MAButton("Continue") {
                    Task { await viewModel.saveProfile() }
                }
                
                Button("Skip") {
                    viewModel.nextStep()
                }
                .font(MAFont.labelMedium)
                .foregroundColor(.textTertiary)
            }
            .padding(.horizontal, MASpacing.xl)
            .padding(.bottom, MASpacing.xxl)
        }
    }
    
    // MARK: - Permissions
    private var permissionsView: some View {
        VStack(spacing: MASpacing.xl) {
            Spacer()
            
            VStack(spacing: MASpacing.md) {
                Text("Enable Features")
                    .font(MAFont.displayMedium)
                    .foregroundColor(.textPrimary)
            }
            
            VStack(spacing: MASpacing.lg) {
                permissionCard(
                    icon: "bell.fill",
                    title: "Notifications",
                    description: "Get prayer reminders and cycle predictions",
                    isEnabled: $viewModel.notificationsEnabled
                )
                
                permissionCard(
                    icon: "location.fill",
                    title: "Location",
                    description: "Accurate prayer times for your location",
                    isEnabled: $viewModel.locationEnabled
                )
            }
            .padding(.horizontal, MASpacing.xl)
            
            Spacer()
            
            MAButton("Continue") {
                Task { await viewModel.requestPermissions() }
            }
            .padding(.horizontal, MASpacing.xl)
            .padding(.bottom, MASpacing.xxl)
        }
    }
    
    private func permissionCard(icon: String, title: String, description: String, isEnabled: Binding<Bool>) -> some View {
        HStack(spacing: MASpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.accentGreenDark)
                .frame(width: 48, height: 48)
                .background(Color.accentGreenDark.opacity(0.1))
                .cornerRadius(MACornerRadius.medium)
            
            VStack(alignment: .leading, spacing: MASpacing.xxs) {
                Text(title)
                    .font(MAFont.titleSmall)
                    .foregroundColor(.textPrimary)
                Text(description)
                    .font(MAFont.bodySmall)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: isEnabled)
                .labelsHidden()
                .tint(.accentGreenDark)
        }
        .padding(MASpacing.lg)
        .background(Color.surfaceContrast.opacity(0.3))
        .cornerRadius(MACornerRadius.medium)
    }
    
    // MARK: - Premium Offer
    private var premiumOfferView: some View {
        VStack(spacing: MASpacing.xl) {
            Spacer()
            
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(.accentGreenDark)
            
            VStack(spacing: MASpacing.md) {
                Text("Try Premium Free")
                    .font(MAFont.displayMedium)
                    .foregroundColor(.textPrimary)
                
                Text("Unlock all features for 7 days")
                    .font(MAFont.bodyMedium)
                    .foregroundColor(.textSecondary)
            }
            
            VStack(alignment: .leading, spacing: MASpacing.md) {
                featureCheck("Deep cycle insights & AI analysis")
                featureCheck("Full community access")
                featureCheck("Create your own spaces")
                featureCheck("Ad-free experience")
            }
            .padding(.horizontal, MASpacing.xl)
            
            Spacer()
            
            VStack(spacing: MASpacing.md) {
                MAButton("Start Free Trial") {
                    viewModel.startTrial()
                    isOnboardingComplete = true
                }
                
                Button("Maybe Later") {
                    isOnboardingComplete = true
                }
                .font(MAFont.labelMedium)
                .foregroundColor(.textTertiary)
            }
            .padding(.horizontal, MASpacing.xl)
            .padding(.bottom, MASpacing.xxl)
        }
    }
    
    private func featureCheck(_ text: String) -> some View {
        HStack(spacing: MASpacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.accentGreenDark)
            Text(text)
                .font(MAFont.bodyMedium)
                .foregroundColor(.textPrimary)
        }
    }
}

// MARK: - Sign In View
struct SignInView: View {
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var error: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: MASpacing.xl) {
                VStack(spacing: MASpacing.lg) {
                    MAInputField(label: "Email", placeholder: "your@email.com", text: $email, keyboardType: .emailAddress)
                    MAInputField(label: "Password", placeholder: "Your password", text: $password, isSecure: true)
                    
                    if let error = error {
                        Text(error).font(MAFont.bodySmall).foregroundColor(.statusError)
                    }
                }
                .padding(.horizontal, MASpacing.xl)
                
                MAButton("Sign In", isLoading: isLoading) {
                    Task {
                        isLoading = true
                        defer { isLoading = false }
                        do {
                            try await SupabaseManager.shared.signIn(email: email, password: password)
                            dismiss()
                            onComplete()
                        } catch {
                            self.error = "Invalid email or password"
                        }
                    }
                }
                .padding(.horizontal, MASpacing.xl)
                
                Spacer()
            }
            .padding(.top, MASpacing.xxl)
            .background(Color.backgroundPrimary)
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
}
