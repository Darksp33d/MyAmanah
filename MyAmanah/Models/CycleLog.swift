import Foundation
import SwiftUI

// MARK: - Cycle Log Model
struct CycleLog: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let logDate: Date
    var periodFlow: PeriodFlow?
    var symptoms: [Symptom]
    var mood: Mood?
    var painLevel: Int?
    var notes: String?
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case logDate = "log_date"
        case periodFlow = "period_flow"
        case symptoms
        case mood
        case painLevel = "pain_level"
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        logDate: Date,
        periodFlow: PeriodFlow? = nil,
        symptoms: [Symptom] = [],
        mood: Mood? = nil,
        painLevel: Int? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.logDate = logDate
        self.periodFlow = periodFlow
        self.symptoms = symptoms
        self.mood = mood
        self.painLevel = painLevel
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var isPeriodDay: Bool {
        guard let flow = periodFlow else { return false }
        return flow != .none
    }
}

// MARK: - Period Flow
enum PeriodFlow: String, Codable, CaseIterable {
    case none
    case spotting
    case light
    case medium
    case heavy
    
    var displayName: String {
        switch self {
        case .none: return "No Period"
        case .spotting: return "Spotting"
        case .light: return "Light"
        case .medium: return "Medium"
        case .heavy: return "Heavy"
        }
    }
    
    var icon: String {
        switch self {
        case .none: return "circle"
        case .spotting: return "drop"
        case .light: return "drop.fill"
        case .medium: return "drop.fill"
        case .heavy: return "drop.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .none: return .textTertiary
        case .spotting: return .cycleMenstrual.opacity(0.5)
        case .light: return .cycleMenstrual.opacity(0.7)
        case .medium: return .cycleMenstrual
        case .heavy: return .cycleMenstrual
        }
    }
}

// MARK: - Symptoms
enum Symptom: String, Codable, CaseIterable {
    // Physical
    case cramps
    case headache
    case fatigue
    case bloating
    case breastTenderness = "breast_tenderness"
    case backache
    case nausea
    case acne
    case insomnia
    case hotFlashes = "hot_flashes"
    
    // Digestive
    case constipation
    case diarrhea
    case appetiteIncrease = "appetite_increase"
    case appetiteDecrease = "appetite_decrease"
    
    // Other
    case dizziness
    case jointPain = "joint_pain"
    case muscleAches = "muscle_aches"
    
    var displayName: String {
        switch self {
        case .cramps: return "Cramps"
        case .headache: return "Headache"
        case .fatigue: return "Fatigue"
        case .bloating: return "Bloating"
        case .breastTenderness: return "Breast Tenderness"
        case .backache: return "Backache"
        case .nausea: return "Nausea"
        case .acne: return "Acne"
        case .insomnia: return "Insomnia"
        case .hotFlashes: return "Hot Flashes"
        case .constipation: return "Constipation"
        case .diarrhea: return "Diarrhea"
        case .appetiteIncrease: return "Appetite Increase"
        case .appetiteDecrease: return "Appetite Decrease"
        case .dizziness: return "Dizziness"
        case .jointPain: return "Joint Pain"
        case .muscleAches: return "Muscle Aches"
        }
    }
    
    var icon: String {
        switch self {
        case .cramps: return "bolt.fill"
        case .headache: return "brain.head.profile"
        case .fatigue: return "battery.25"
        case .bloating: return "circle.fill"
        case .breastTenderness: return "heart.fill"
        case .backache: return "figure.walk"
        case .nausea: return "stomach"
        case .acne: return "face.smiling"
        case .insomnia: return "moon.zzz"
        case .hotFlashes: return "thermometer.sun"
        case .constipation: return "arrow.down.circle"
        case .diarrhea: return "arrow.up.circle"
        case .appetiteIncrease: return "fork.knife"
        case .appetiteDecrease: return "fork.knife"
        case .dizziness: return "tornado"
        case .jointPain: return "figure.arms.open"
        case .muscleAches: return "figure.strengthtraining.traditional"
        }
    }
    
    static var physical: [Symptom] {
        [.cramps, .headache, .fatigue, .bloating, .breastTenderness, .backache, .nausea, .acne, .insomnia, .hotFlashes]
    }
    
    static var digestive: [Symptom] {
        [.constipation, .diarrhea, .appetiteIncrease, .appetiteDecrease]
    }
    
    static var other: [Symptom] {
        [.dizziness, .jointPain, .muscleAches]
    }
}

// MARK: - Mood
enum Mood: String, Codable, CaseIterable {
    case happy
    case calm
    case energetic
    case focused
    case anxious
    case irritable
    case sad
    case moody
    case overwhelmed
    case neutral
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .calm: return "😌"
        case .energetic: return "⚡"
        case .focused: return "🎯"
        case .anxious: return "😰"
        case .irritable: return "😤"
        case .sad: return "😢"
        case .moody: return "🌊"
        case .overwhelmed: return "😵"
        case .neutral: return "😐"
        }
    }
    
    var color: Color {
        switch self {
        case .happy, .calm, .energetic, .focused:
            return .statusSuccess
        case .anxious, .irritable, .sad, .moody, .overwhelmed:
            return .statusWarning
        case .neutral:
            return .textSecondary
        }
    }
    
    static var positive: [Mood] {
        [.happy, .calm, .energetic, .focused]
    }
    
    static var negative: [Mood] {
        [.anxious, .irritable, .sad, .moody, .overwhelmed]
    }
}

// MARK: - Cycle Prediction
struct CyclePrediction: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let predictedStartDate: Date
    let predictedEndDate: Date?
    let predictedOvulationDate: Date?
    let confidence: PredictionConfidence
    let algorithmVersion: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case predictedStartDate = "predicted_start_date"
        case predictedEndDate = "predicted_end_date"
        case predictedOvulationDate = "predicted_ovulation_date"
        case confidence
        case algorithmVersion = "algorithm_version"
        case createdAt = "created_at"
    }
}

enum PredictionConfidence: String, Codable {
    case low
    case medium
    case high
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var color: Color {
        switch self {
        case .low: return .statusWarning
        case .medium: return .statusInfo
        case .high: return .statusSuccess
        }
    }
}

// MARK: - Cycle Phase
enum CyclePhase: String, CaseIterable {
    case menstrual
    case follicular
    case ovulation
    case luteal
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var color: Color {
        switch self {
        case .menstrual: return .cycleMenstrual
        case .follicular: return .cycleFollicular
        case .ovulation: return .cycleOvulation
        case .luteal: return .cycleLuteal
        }
    }
    
    var description: String {
        switch self {
        case .menstrual: return "Your period phase"
        case .follicular: return "Pre-ovulation phase"
        case .ovulation: return "Fertility window"
        case .luteal: return "Post-ovulation phase"
        }
    }
    
    var dayRange: ClosedRange<Int> {
        switch self {
        case .menstrual: return 1...5
        case .follicular: return 6...13
        case .ovulation: return 14...16
        case .luteal: return 17...28
        }
    }
    
    static func phase(forDay day: Int, cycleLength: Int = 28) -> CyclePhase {
        let adjustedOvulation = cycleLength - 14
        
        if day <= 5 {
            return .menstrual
        } else if day < adjustedOvulation - 2 {
            return .follicular
        } else if day <= adjustedOvulation + 2 {
            return .ovulation
        } else {
            return .luteal
        }
    }
}

// MARK: - Cycle Statistics
struct CycleStatistics {
    let averageCycleLength: Double
    let averagePeriodLength: Double
    let cycleRegularity: Double // 0-100
    let completedCycles: Int
    let totalLogsCount: Int
    
    var isRegular: Bool {
        cycleRegularity >= 80
    }
}
