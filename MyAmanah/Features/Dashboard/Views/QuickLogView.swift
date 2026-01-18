import SwiftUI
import Combine

struct QuickLogView: View {
    @Binding var isPresented: Bool
    @StateObject private var viewModel = QuickLogViewModel()
    
    var body: some View {
        VStack(spacing: MASpacing.lg) {
            // Period Flow Selection
            VStack(alignment: .leading, spacing: MASpacing.md) {
                Text("Period Status")
                    .font(MAFont.titleSmall)
                    .foregroundColor(.textPrimary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: MASpacing.sm) {
                        ForEach(PeriodFlow.allCases, id: \.self) { flow in
                            periodFlowButton(flow)
                        }
                    }
                }
            }
            
            // Symptoms Selection
            VStack(alignment: .leading, spacing: MASpacing.md) {
                Text("Symptoms")
                    .font(MAFont.titleSmall)
                    .foregroundColor(.textPrimary)
                
                FlowLayout(spacing: MASpacing.sm) {
                    ForEach(Symptom.allCases, id: \.self) { symptom in
                        MATag(
                            symptom.displayName,
                            isSelected: viewModel.selectedSymptoms.contains(symptom),
                            color: .accentGreenDark
                        ) {
                            viewModel.toggleSymptom(symptom)
                        }
                    }
                }
            }
            
            // Mood Selection
            VStack(alignment: .leading, spacing: MASpacing.md) {
                Text("Mood")
                    .font(MAFont.titleSmall)
                    .foregroundColor(.textPrimary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: MASpacing.sm) {
                        ForEach(Mood.allCases, id: \.self) { mood in
                            moodButton(mood)
                        }
                    }
                }
            }
            
            // Pain Level
            if viewModel.selectedFlow != nil && viewModel.selectedFlow != .none {
                VStack(alignment: .leading, spacing: MASpacing.md) {
                    HStack {
                        Text("Pain Level")
                            .font(MAFont.titleSmall)
                            .foregroundColor(.textPrimary)
                        Spacer()
                        Text("\(Int(viewModel.painLevel))/10")
                            .font(MAFont.labelMedium)
                            .foregroundColor(.textSecondary)
                    }
                    
                    Slider(value: $viewModel.painLevel, in: 0...10, step: 1)
                        .tint(.accentGreenDark)
                }
            }
            
            // Save Button
            MAButton("Save", isLoading: viewModel.isLoading) {
                Task {
                    await viewModel.saveLog()
                    isPresented = false
                }
            }
            .padding(.top, MASpacing.md)
        }
    }
    
    private func periodFlowButton(_ flow: PeriodFlow) -> some View {
        Button(action: { viewModel.selectedFlow = flow }) {
            VStack(spacing: MASpacing.xs) {
                Image(systemName: flow.icon)
                    .font(.system(size: 24))
                    .foregroundColor(viewModel.selectedFlow == flow ? .textInverse : flow.color)
                Text(flow.displayName)
                    .font(MAFont.labelSmall)
                    .foregroundColor(viewModel.selectedFlow == flow ? .textInverse : .textPrimary)
            }
            .frame(width: 70, height: 70)
            .background(viewModel.selectedFlow == flow ? flow.color : Color.surfaceContrast)
            .cornerRadius(MACornerRadius.medium)
        }
    }
    
    private func moodButton(_ mood: Mood) -> some View {
        Button(action: { viewModel.selectedMood = mood }) {
            VStack(spacing: MASpacing.xs) {
                Text(mood.emoji)
                    .font(.system(size: 28))
                Text(mood.displayName)
                    .font(MAFont.labelSmall)
                    .foregroundColor(viewModel.selectedMood == mood ? .textInverse : .textPrimary)
            }
            .frame(width: 70, height: 70)
            .background(viewModel.selectedMood == mood ? mood.color : Color.surfaceContrast)
            .cornerRadius(MACornerRadius.medium)
        }
    }
}

@MainActor
final class QuickLogViewModel: ObservableObject {
    @Published var selectedFlow: PeriodFlow?
    @Published var selectedSymptoms: Set<Symptom> = []
    @Published var selectedMood: Mood?
    @Published var painLevel: Double = 0
    @Published var isLoading = false
    
    private let cycleService = CycleService.shared
    private let supabase = SupabaseManager.shared
    
    func toggleSymptom(_ symptom: Symptom) {
        if selectedSymptoms.contains(symptom) {
            selectedSymptoms.remove(symptom)
        } else if selectedSymptoms.count < AppConfig.maxSymptomsPerLog {
            selectedSymptoms.insert(symptom)
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func saveLog() async {
        guard let userId = supabase.currentUser?.id else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let log = CycleLog(
            userId: userId,
            logDate: Date(),
            periodFlow: selectedFlow,
            symptoms: Array(selectedSymptoms),
            mood: selectedMood,
            painLevel: painLevel > 0 ? Int(painLevel) : nil
        )
        
        do {
            try await cycleService.saveLog(log)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}

#Preview {
    QuickLogView(isPresented: .constant(true))
        .background(Color.backgroundPrimary)
}
