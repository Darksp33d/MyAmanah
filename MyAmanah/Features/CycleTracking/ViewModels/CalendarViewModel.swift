import SwiftUI
import Combine

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published var currentMonth: Date = Date()
    @Published var daysInMonth: [Date?] = []
    
    private let cycleService = CycleService.shared
    private let supabase = SupabaseManager.shared
    private let calendar = Calendar.current
    
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    var weekdaySymbols: [String] {
        calendar.veryShortWeekdaySymbols
    }
    
    init() {
        generateDaysInMonth()
    }
    
    func loadData() async {
        if let userId = supabase.currentUser?.id {
            await cycleService.fetchLogs(for: userId)
        }
    }
    
    func previousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        generateDaysInMonth()
    }
    
    func nextMonth() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        generateDaysInMonth()
    }
    
    func generateDaysInMonth() {
        var days: [Date?] = []
        
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let paddingDays = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        for _ in 0..<paddingDays {
            days.append(nil)
        }
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        
        daysInMonth = days
    }
    
    func log(for date: Date) -> CycleLog? {
        cycleService.logs.first { calendar.isDate($0.logDate, inSameDayAs: date) }
    }
    
    func prediction(for date: Date) -> CyclePrediction? {
        cycleService.predictions.first { pred in
            if let start = calendar.date(byAdding: .day, value: -1, to: pred.predictedStartDate),
               let end = pred.predictedEndDate ?? calendar.date(byAdding: .day, value: 5, to: pred.predictedStartDate) {
                return date >= start && date <= end
            }
            return false
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}
