import SwiftUI
import Combine

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showSubscription = false
    @State private var showExport = false
    @State private var showDeleteConfirm = false
    
    var body: some View {
        NavigationStack {
            List {
                // Profile Section
                Section {
                    profileRow
                }
                
                // Subscription
                Section {
                    subscriptionRow
                }
                
                // Preferences
                Section("Preferences") {
                    NavigationLink(destination: NotificationSettingsView()) {
                        settingsRow(icon: "bell.fill", title: "Notifications", color: .statusError)
                    }
                    NavigationLink(destination: AthaanSettingsView()) {
                        settingsRow(icon: "moon.stars.fill", title: "Prayer Times", color: .accentGreenDark)
                    }
                    NavigationLink(destination: CycleSettingsView()) {
                        settingsRow(icon: "calendar", title: "Cycle Settings", color: .cycleMenstrual)
                    }
                }
                
                // Data & Privacy
                Section("Data & Privacy") {
                    NavigationLink(destination: SavedQuotesView()) {
                        settingsRow(icon: "heart.fill", title: "Saved Quotes", color: .statusError)
                    }
                    Button(action: { showExport = true }) {
                        settingsRow(icon: "square.and.arrow.up", title: "Export My Data", color: .statusInfo)
                    }
                    NavigationLink(destination: PrivacySettingsView()) {
                        settingsRow(icon: "hand.raised.fill", title: "Privacy", color: .accentBrown)
                    }
                }
                
                // Support
                Section("Support") {
                    Link(destination: AppConfig.privacyPolicyURL) {
                        settingsRow(icon: "doc.text.fill", title: "Privacy Policy", color: .textSecondary)
                    }
                    Link(destination: AppConfig.termsOfServiceURL) {
                        settingsRow(icon: "doc.fill", title: "Terms of Service", color: .textSecondary)
                    }
                    Button(action: { viewModel.contactSupport() }) {
                        settingsRow(icon: "envelope.fill", title: "Contact Support", color: .statusInfo)
                    }
                }
                
                // Account
                Section {
                    Button(action: { Task { await viewModel.signOut() } }) {
                        HStack {
                            Text("Sign Out")
                                .foregroundColor(.textPrimary)
                            Spacer()
                        }
                    }
                    
                    Button(role: .destructive, action: { showDeleteConfirm = true }) {
                        HStack {
                            Text("Delete Account")
                                .foregroundColor(.statusError)
                            Spacer()
                        }
                    }
                }
                
                // App Info
                Section {
                    HStack {
                        Text("Version")
                            .foregroundColor(.textPrimary)
                        Spacer()
                        Text(viewModel.appVersion)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.backgroundPrimary)
            .navigationTitle("Settings")
            .sheet(isPresented: $showSubscription) {
                SubscriptionView()
            }
            .sheet(isPresented: $showExport) {
                ExportDataView()
            }
            .alert("Delete Account", isPresented: $showDeleteConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task { await viewModel.deleteAccount() }
                }
            } message: {
                Text("This will permanently delete your account and all data. This action cannot be undone.")
            }
        }
    }
    
    private var profileRow: some View {
        HStack(spacing: MASpacing.md) {
            Circle()
                .fill(Color.accentGreenLight.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Text(viewModel.userInitials)
                        .font(MAFont.titleLarge)
                        .foregroundColor(.accentGreenDark)
                )
            
            VStack(alignment: .leading, spacing: MASpacing.xxs) {
                Text(viewModel.displayName)
                    .font(MAFont.titleMedium)
                    .foregroundColor(.textPrimary)
                Text(viewModel.email)
                    .font(MAFont.bodySmall)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            NavigationLink(destination: EditProfileView()) {
                EmptyView()
            }
            .frame(width: 0)
            .opacity(0)
        }
        .padding(.vertical, MASpacing.xs)
    }
    
    private var subscriptionRow: some View {
        Button(action: { showSubscription = true }) {
            HStack {
                VStack(alignment: .leading, spacing: MASpacing.xxs) {
                    HStack {
                        Text(viewModel.isPremium ? "Premium" : "Free Plan")
                            .font(MAFont.titleSmall)
                            .foregroundColor(.textPrimary)
                        
                        if viewModel.isPremium {
                            MAStatusBadge(status: "Active", color: .accentGreenDark)
                        }
                    }
                    
                    Text(viewModel.subscriptionStatus)
                        .font(MAFont.bodySmall)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                if !viewModel.isPremium {
                    Text("Upgrade")
                        .font(MAFont.labelMedium)
                        .foregroundColor(.accentGreenDark)
                }
            }
        }
    }
    
    private func settingsRow(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: MASpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.15))
                .cornerRadius(6)
            
            Text(title)
                .font(MAFont.bodyLarge)
                .foregroundColor(.textPrimary)
            
            Spacer()
        }
    }
}

// MARK: - Settings ViewModel
@MainActor
final class SettingsViewModel: ObservableObject {
    private let supabase = SupabaseManager.shared
    
    var displayName: String {
        supabase.currentUser?.displayName ?? "User"
    }
    
    var email: String {
        "user@example.com"
    }
    
    var userInitials: String {
        String(displayName.prefix(2)).uppercased()
    }
    
    var isPremium: Bool {
        supabase.currentUser?.isPremium ?? false
    }
    
    var subscriptionStatus: String {
        if isPremium {
            if let expires = supabase.currentUser?.premiumExpiresAt {
                return "Renews \(expires.formatted(date: .abbreviated, time: .omitted))"
            }
            return "Active subscription"
        }
        return "Upgrade for full access"
    }
    
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
    
    func signOut() async {
        try? await supabase.signOut()
    }
    
    func deleteAccount() async {
        // Implementation for account deletion
    }
    
    func contactSupport() {
        if let url = URL(string: "mailto:\(AppConfig.supportEmail)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Placeholder Views
struct NotificationSettingsView: View {
    var body: some View {
        List {
            Section("Prayer Notifications") {
                ForEach(Prayer.prayers, id: \.self) { prayer in
                    Toggle(prayer.displayName, isOn: .constant(true))
                }
            }
            Section("Cycle Notifications") {
                Toggle("Period Reminders", isOn: .constant(true))
                Toggle("Daily Check-in", isOn: .constant(false))
            }
        }
        .navigationTitle("Notifications")
    }
}

struct CycleSettingsView: View {
    @State private var cycleLength = 28
    @State private var fertileWindowEnabled = false
    
    var body: some View {
        List {
            Section("Cycle Length") {
                Stepper("\(cycleLength) days", value: $cycleLength, in: 21...35)
            }
            Section("Fertility") {
                Toggle("Show Fertile Window", isOn: $fertileWindowEnabled)
                Text("Predictions are estimates and should not be used for contraception.")
                    .font(MAFont.bodySmall)
                    .foregroundColor(.textTertiary)
            }
        }
        .navigationTitle("Cycle Settings")
    }
}

struct PrivacySettingsView: View {
    @State private var analyticsEnabled = true
    @State private var crashReportingEnabled = true
    
    var body: some View {
        List {
            Section(footer: Text("Help us improve the app by sharing anonymous usage data.")) {
                Toggle("Analytics", isOn: $analyticsEnabled)
                Toggle("Crash Reporting", isOn: $crashReportingEnabled)
            }
        }
        .navigationTitle("Privacy")
    }
}

struct SavedQuotesView: View {
    @StateObject private var quoteService = QuoteService.shared
    
    var body: some View {
        List {
            if quoteService.savedContent.isEmpty {
                MAEmptyState(
                    icon: "heart",
                    title: "No Saved Quotes",
                    description: "Tap the heart on any quote to save it"
                )
            } else {
                ForEach(quoteService.savedContent) { saved in
                    if let content = quoteService.content(for: saved) {
                        VStack(alignment: .leading, spacing: MASpacing.sm) {
                            Text(content.text)
                                .font(MAFont.bodyMedium)
                            Text(content.attribution)
                                .font(MAFont.labelSmall)
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.vertical, MASpacing.xs)
                    }
                }
            }
        }
        .navigationTitle("Saved Quotes")
    }
}

struct EditProfileView: View {
    @State private var displayName = ""
    
    var body: some View {
        Form {
            Section("Profile") {
                TextField("Display Name", text: $displayName)
            }
        }
        .navigationTitle("Edit Profile")
    }
}

struct ExportDataView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRange = 0
    @State private var selectedFormat = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: MASpacing.xl) {
                Picker("Date Range", selection: $selectedRange) {
                    Text("Last 3 months").tag(0)
                    Text("Last 6 months").tag(1)
                    Text("Last year").tag(2)
                    Text("All time").tag(3)
                }
                .pickerStyle(.segmented)
                
                Picker("Format", selection: $selectedFormat) {
                    Text("CSV").tag(0)
                    Text("PDF").tag(1)
                }
                .pickerStyle(.segmented)
                
                Spacer()
                
                MAButton("Generate Export") {
                    dismiss()
                }
            }
            .padding(MASpacing.lg)
            .navigationTitle("Export Data")
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
    SettingsView()
}
