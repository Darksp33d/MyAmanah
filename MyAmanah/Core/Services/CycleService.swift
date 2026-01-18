import Foundation
import Combine

// MARK: - Cycle Service
@MainActor
final class CycleService: ObservableObject {
    static let shared = CycleService()
    
    private let supabase = SupabaseManager.shared
    
    @Published private(set) var logs: [CycleLog] = []
    @Published private(set) var predictions: [CyclePrediction] = []
    @Published private(set) var statistics: CycleStatistics?
    @Published private(set) var isLoading = false
    @Published var error: Error?
    
    private init() {}
    
    // MARK: - Fetch Logs
    func fetchLogs(for userId: UUID) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            logs = try await supabase.fetch(from: "cycle_logs") { query in
                query
                    .eq("user_id", value: userId.uuidString)
                    .order("log_date", ascending: false)
            }
            calculateStatistics()
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Save Log
    func saveLog(_ log: CycleLog) async throws {
        let existingLogs: [CycleLog] = try await supabase.fetch(from: "cycle_logs") { query in
            query
                .eq("user_id", value: log.userId.uuidString)
                .eq("log_date", value: ISO8601DateFormatter().string(from: log.logDate))
        }
        
        if let existing = existingLogs.first {
            var updated = log
            updated = CycleLog(
                id: existing.id, userId: log.userId, logDate: log.logDate,
                periodFlow: log.periodFlow, symptoms: log.symptoms, mood: log.mood,
                painLevel: log.painLevel, notes: log.notes,
                createdAt: existing.createdAt, updatedAt: Date()
            )
            try await supabase.update(table: "cycle_logs", value: updated) { $0.eq("id", value: existing.id.uuidString) }
            if let idx = logs.firstIndex(where: { $0.id == existing.id }) { logs[idx] = updated }
        } else {
            try await supabase.insert(into: "cycle_logs", value: log)
            logs.insert(log, at: 0)
            logs.sort { $0.logDate > $1.logDate }
        }
        calculateStatistics()
        await updatePredictions(for: log.userId)
    }
    
    // MARK: - Statistics
    private func calculateStatistics() {
        guard !logs.isEmpty else { statistics = nil; return }
        let cycles = detectCycles()
        guard cycles.count >= 2 else {
            statistics = CycleStatistics(averageCycleLength: 28, averagePeriodLength: 5, cycleRegularity: 0, completedCycles: 0, totalLogsCount: logs.count)
            return
        }
        let avgCycle = cycles.map { $0.length }.reduce(0, +) / Double(cycles.count)
        let avgPeriod = cycles.map { $0.periodLength }.reduce(0, +) / Double(cycles.count)
        let variance = cycles.map { pow($0.length - avgCycle, 2) }.reduce(0, +) / Double(cycles.count)
        let regularity = max(0, min(100, 100 - (sqrt(variance) * 10)))
        statistics = CycleStatistics(averageCycleLength: avgCycle, averagePeriodLength: avgPeriod, cycleRegularity: regularity, completedCycles: cycles.count, totalLogsCount: logs.count)
    }
    
    private func detectCycles() -> [(startDate: Date, length: Double, periodLength: Double)] {
        let periodLogs = logs.filter { $0.isPeriodDay }.sorted { $0.logDate < $1.logDate }
        guard !periodLogs.isEmpty else { return [] }
        var cycles: [(Date, Double, Double)] = []
        var cycleStart: Date?
        var periodDays: [Date] = []
        for log in periodLogs {
            if let last = periodDays.last {
                let gap = Calendar.current.dateComponents([.day], from: last, to: log.logDate).day ?? 0
                if gap > 3 {
                    if let start = cycleStart {
                        let len = Calendar.current.dateComponents([.day], from: start, to: log.logDate).day ?? 28
                        cycles.append((start, Double(len), Double(periodDays.count)))
                    }
                    cycleStart = log.logDate
                    periodDays = [log.logDate]
                } else { periodDays.append(log.logDate) }
            } else { cycleStart = log.logDate; periodDays = [log.logDate] }
        }
        return cycles
    }
    
    func updatePredictions(for userId: UUID) async {
        let cycles = detectCycles()
        guard cycles.count >= 2, let lastStart = cycles.last?.startDate else { predictions = []; return }
        let weights = [0.30, 0.25, 0.20, 0.12, 0.08, 0.05]
        let recent = Array(cycles.suffix(6))
        var wSum = 0.0, tWeight = 0.0
        for (i, c) in recent.reversed().enumerated() {
            let w = i < weights.count ? weights[i] : 0.05
            wSum += c.length * w; tWeight += w
        }
        let predLen = wSum / tWeight
        let stdDev = sqrt(recent.map { pow($0.length - predLen, 2) }.reduce(0, +) / Double(recent.count))
        let conf: PredictionConfidence = stdDev < 3 ? .high : stdDev < 7 ? .medium : .low
        var next = lastStart
        predictions = (0..<3).map { _ in
            next = Calendar.current.date(byAdding: .day, value: Int(predLen), to: next)!
            return CyclePrediction(id: UUID(), userId: userId, predictedStartDate: next, predictedEndDate: Calendar.current.date(byAdding: .day, value: 5, to: next), predictedOvulationDate: Calendar.current.date(byAdding: .day, value: -14, to: next), confidence: conf, algorithmVersion: "v1", createdAt: Date())
        }
    }
    
    var currentCycleDay: Int? {
        guard let start = logs.first(where: { $0.isPeriodDay })?.logDate else { return nil }
        return (Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0) + 1
    }
    
    var currentPhase: CyclePhase? {
        guard let day = currentCycleDay else { return nil }
        return CyclePhase.phase(forDay: day, cycleLength: Int(statistics?.averageCycleLength ?? 28))
    }
    
    var daysUntilNextPeriod: Int? {
        guard let next = predictions.first?.predictedStartDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: next).day
    }
}
