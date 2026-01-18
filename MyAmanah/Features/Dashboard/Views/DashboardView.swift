import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showLogSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: MASpacing.lg) {
                    // Cycle Status Card
                    cycleStatusCard
                    
                    // Quick Log Button
                    quickLogCard
                    
                    // Prayer Time Summary
                    prayerTimeSummaryCard
                    
                    // Daily Quote/Hadith
                    dailyContentCard
                    
                    // Recommendations
                    if !viewModel.recommendations.isEmpty {
                        recommendationsSection
                    }
                }
                .padding(.horizontal, MASpacing.lg)
                .padding(.vertical, MASpacing.md)
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Home")
            .refreshable {
                await viewModel.refresh()
            }
        }
        .maSheet(isPresented: $showLogSheet, title: "Log Today") {
            QuickLogView(isPresented: $showLogSheet)
        }
        .task {
            await viewModel.loadData()
        }
    }
    
    // MARK: - Cycle Status Card
    private var cycleStatusCard: some View {
        MACard(variant: .elevated, action: { }) {
            HStack(spacing: MASpacing.lg) {
                // Cycle Day Circle
                ZStack {
                    Circle()
                        .stroke(viewModel.currentPhase?.color ?? .borderDefault, lineWidth: 6)
                        .frame(width: 80, height: 80)
                    
                    VStack(spacing: 2) {
                        Text("Day")
                            .font(MAFont.labelSmall)
                            .foregroundColor(.textSecondary)
                        Text(viewModel.cycleDay)
                            .font(MAFont.displayMedium)
                            .foregroundColor(.textPrimary)
                    }
                }
                
                VStack(alignment: .leading, spacing: MASpacing.xs) {
                    Text(viewModel.phaseTitle)
                        .font(MAFont.titleMedium)
                        .foregroundColor(.textPrimary)
                    
                    Text(viewModel.phaseDescription)
                        .font(MAFont.bodyMedium)
                        .foregroundColor(.textSecondary)
                    
                    if let daysUntil = viewModel.daysUntilPeriod {
                        HStack(spacing: MASpacing.xs) {
                            Image(systemName: "calendar")
                                .font(.system(size: 12))
                            Text("Period in \(daysUntil) days")
                                .font(MAFont.labelMedium)
                        }
                        .foregroundColor(viewModel.currentPhase?.color ?? .textTertiary)
                        .padding(.top, MASpacing.xs)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.textTertiary)
            }
        }
    }
    
    // MARK: - Quick Log Card
    private var quickLogCard: some View {
        MACard(variant: .interactive, action: { showLogSheet = true }) {
            HStack {
                Circle()
                    .fill(Color.accentGreenDark.opacity(0.15))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.accentGreenDark)
                    )
                
                VStack(alignment: .leading, spacing: MASpacing.xxs) {
                    Text("Log Today")
                        .font(MAFont.titleMedium)
                        .foregroundColor(.textPrimary)
                    Text("Track your symptoms and mood")
                        .font(MAFont.bodySmall)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.textTertiary)
            }
        }
    }
    
    // MARK: - Prayer Time Summary
    private var prayerTimeSummaryCard: some View {
        MACard(action: { }) {
            HStack {
                Image(systemName: viewModel.nextPrayer?.icon ?? "moon.stars")
                    .font(.system(size: 24))
                    .foregroundColor(viewModel.nextPrayer?.color ?? .accentGreenDark)
                    .frame(width: 48, height: 48)
                    .background(Color.surfaceContrast)
                    .cornerRadius(MACornerRadius.medium)
                
                VStack(alignment: .leading, spacing: MASpacing.xxs) {
                    Text(viewModel.nextPrayer?.displayName ?? "Prayer Times")
                        .font(MAFont.titleMedium)
                        .foregroundColor(.textPrimary)
                    Text(viewModel.nextPrayerTime)
                        .font(MAFont.bodySmall)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Text(viewModel.prayerCountdown)
                    .font(MAFont.labelMedium)
                    .foregroundColor(.accentGreenDark)
            }
        }
    }
    
    // MARK: - Daily Content Card
    private var dailyContentCard: some View {
        MACard(variant: .featured) {
            VStack(alignment: .leading, spacing: MASpacing.md) {
                HStack {
                    Image(systemName: "quote.opening")
                        .foregroundColor(.accentGreenLight)
                    Spacer()
                    Button(action: { viewModel.toggleSaveContent() }) {
                        Image(systemName: viewModel.isContentSaved ? "heart.fill" : "heart")
                            .foregroundColor(viewModel.isContentSaved ? .statusError : .textTertiary)
                    }
                    Button(action: { viewModel.shareContent() }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.textTertiary)
                    }
                }
                
                Text(viewModel.dailyContentText)
                    .font(MAFont.bodyLarge)
                    .foregroundColor(.textPrimary)
                    .lineSpacing(6)
                
                Text(viewModel.dailyContentAttribution)
                    .font(MAFont.labelMedium)
                    .foregroundColor(.textSecondary)
            }
        }
    }
    
    // MARK: - Recommendations
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: MASpacing.md) {
            Text("For You")
                .font(MAFont.titleMedium)
                .foregroundColor(.textPrimary)
            
            ForEach(viewModel.recommendations, id: \.title) { rec in
                MACard {
                    HStack(spacing: MASpacing.md) {
                        Image(systemName: rec.icon)
                            .font(.system(size: 20))
                            .foregroundColor(.accentGreenDark)
                            .frame(width: 40, height: 40)
                            .background(Color.accentGreenDark.opacity(0.1))
                            .cornerRadius(MACornerRadius.small)
                        
                        VStack(alignment: .leading, spacing: MASpacing.xxs) {
                            Text(rec.title)
                                .font(MAFont.titleSmall)
                                .foregroundColor(.textPrimary)
                            Text(rec.body)
                                .font(MAFont.bodySmall)
                                .foregroundColor(.textSecondary)
                                .lineLimit(2)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    DashboardView()
}
