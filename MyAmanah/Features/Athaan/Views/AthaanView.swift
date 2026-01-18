import SwiftUI

struct AthaanView: View {
    @StateObject private var viewModel = AthaanViewModel()
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: MASpacing.lg) {
                    // Location Card
                    locationCard
                    
                    // Next Prayer Highlight
                    if let next = viewModel.nextPrayer {
                        nextPrayerCard(next)
                    }
                    
                    // All Prayer Times
                    prayerTimesList
                    
                    // Qibla Direction
                    if let qibla = viewModel.qiblaDirection {
                        qiblaCard(qibla)
                    }
                }
                .padding(.horizontal, MASpacing.lg)
                .padding(.vertical, MASpacing.md)
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Athaan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.accentGreenDark)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                AthaanSettingsView()
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
    
    // MARK: - Location Card
    private var locationCard: some View {
        HStack {
            Image(systemName: "location.fill")
                .foregroundColor(.accentGreenDark)
            
            Text(viewModel.locationName)
                .font(MAFont.bodyMedium)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Text(viewModel.calculationMethod)
                .font(MAFont.labelSmall)
                .foregroundColor(.textSecondary)
        }
        .padding(MASpacing.md)
        .background(Color.surfaceContrast.opacity(0.3))
        .cornerRadius(MACornerRadius.medium)
    }
    
    // MARK: - Next Prayer Card
    private func nextPrayerCard(_ prayerTime: PrayerTime) -> some View {
        MACard(variant: .elevated) {
            VStack(spacing: MASpacing.md) {
                HStack {
                    Text("Next Prayer")
                        .font(MAFont.labelMedium)
                        .foregroundColor(.textSecondary)
                    Spacer()
                    if let countdown = prayerTime.timeUntil {
                        Text(countdown)
                            .font(MAFont.labelMedium)
                            .foregroundColor(.accentGreenDark)
                    }
                }
                
                HStack(alignment: .center, spacing: MASpacing.lg) {
                    Image(systemName: prayerTime.prayer.icon)
                        .font(.system(size: 40))
                        .foregroundColor(prayerTime.prayer.color)
                    
                    VStack(alignment: .leading, spacing: MASpacing.xxs) {
                        Text(prayerTime.prayer.displayName)
                            .font(MAFont.displaySmall)
                            .foregroundColor(.textPrimary)
                        Text(prayerTime.prayer.arabicName)
                            .font(MAFont.bodyMedium)
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                    
                    Text(prayerTime.formattedTime)
                        .font(MAFont.displayMedium)
                        .foregroundColor(.textPrimary)
                }
            }
        }
    }
    
    // MARK: - Prayer Times List
    private var prayerTimesList: some View {
        VStack(spacing: MASpacing.sm) {
            ForEach(viewModel.prayerTimes) { prayerTime in
                prayerTimeRow(prayerTime)
            }
        }
    }
    
    private func prayerTimeRow(_ prayerTime: PrayerTime) -> some View {
        HStack {
            Image(systemName: prayerTime.prayer.icon)
                .font(.system(size: 20))
                .foregroundColor(prayerTime.prayer.color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(prayerTime.prayer.displayName)
                    .font(MAFont.titleSmall)
                    .foregroundColor(prayerTime.isNext ? .textPrimary : (prayerTime.isPassed ? .textTertiary : .textPrimary))
                
                if !prayerTime.prayer.isPrayer {
                    Text("Not a prayer time")
                        .font(MAFont.labelSmall)
                        .foregroundColor(.textTertiary)
                }
            }
            
            Spacer()
            
            Text(prayerTime.formattedTime)
                .font(prayerTime.isNext ? MAFont.titleMedium : MAFont.bodyMedium)
                .foregroundColor(prayerTime.isNext ? .accentGreenDark : (prayerTime.isPassed ? .textTertiary : .textPrimary))
            
            if prayerTime.isNext {
                Circle()
                    .fill(Color.accentGreenDark)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(MASpacing.md)
        .background(prayerTime.isNext ? Color.accentGreenDark.opacity(0.1) : Color.clear)
        .cornerRadius(MACornerRadius.medium)
    }
    
    // MARK: - Qibla Card
    private func qiblaCard(_ qibla: QiblaDirection) -> some View {
        MACard {
            HStack {
                Image(systemName: "location.north.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.accentGreenDark)
                    .rotationEffect(.degrees(qibla.degrees))
                
                VStack(alignment: .leading, spacing: MASpacing.xxs) {
                    Text("Qibla Direction")
                        .font(MAFont.titleSmall)
                        .foregroundColor(.textPrimary)
                    Text("\(Int(qibla.degrees))° \(qibla.cardinalDirection)")
                        .font(MAFont.bodyMedium)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Athaan Settings View
struct AthaanSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AthaanSettingsViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Location") {
                    Picker("Mode", selection: $viewModel.locationMode) {
                        Text("Automatic").tag(LocationMode.auto)
                        Text("Manual").tag(LocationMode.manual)
                    }
                    
                    if viewModel.locationMode == .manual {
                        TextField("City", text: $viewModel.manualCity)
                    }
                }
                
                Section("Calculation Method") {
                    Picker("Method", selection: $viewModel.calculationMethod) {
                        ForEach(PrayerCalculationMethod.allCases, id: \.self) { method in
                            Text(method.displayName).tag(method)
                        }
                    }
                }
                
                Section("Asr Calculation") {
                    Picker("Method", selection: $viewModel.asrMethod) {
                        ForEach(AsrCalculationMethod.allCases, id: \.self) { method in
                            Text(method.displayName).tag(method)
                        }
                    }
                }
                
                Section("Notifications") {
                    ForEach(Prayer.prayers, id: \.self) { prayer in
                        Toggle(prayer.displayName, isOn: viewModel.binding(for: prayer))
                    }
                }
            }
            .navigationTitle("Prayer Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task {
                            await viewModel.save()
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    AthaanView()
}
