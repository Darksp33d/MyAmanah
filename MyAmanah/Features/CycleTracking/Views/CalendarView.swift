import SwiftUI

struct CycleCalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var selectedDate: Date = Date()
    @State private var showDayDetail = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Month Header
                monthHeader
                
                // Weekday Headers
                weekdayHeaders
                
                // Calendar Grid
                calendarGrid
                
                Divider()
                    .padding(.vertical, MASpacing.md)
                
                // Selected Day Info
                selectedDayInfo
                
                Spacer()
            }
            .padding(.horizontal, MASpacing.lg)
            .background(Color.backgroundPrimary)
            .navigationTitle("Track")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { selectedDate = Date() }) {
                        Text("Today")
                            .font(MAFont.labelMedium)
                            .foregroundColor(.accentGreenDark)
                    }
                }
            }
        }
        .maSheet(isPresented: $showDayDetail, title: viewModel.formattedDate(selectedDate)) {
            DayDetailView(date: selectedDate, isPresented: $showDayDetail)
        }
        .task {
            await viewModel.loadData()
        }
    }
    
    // MARK: - Month Header
    private var monthHeader: some View {
        HStack {
            Button(action: { viewModel.previousMonth() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.accentGreenDark)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            Text(viewModel.monthYearString)
                .font(MAFont.titleLarge)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Button(action: { viewModel.nextMonth() }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.accentGreenDark)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.vertical, MASpacing.md)
    }
    
    // MARK: - Weekday Headers
    private var weekdayHeaders: some View {
        HStack(spacing: 0) {
            ForEach(viewModel.weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(MAFont.labelSmall)
                    .foregroundColor(.textTertiary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.bottom, MASpacing.sm)
    }
    
    // MARK: - Calendar Grid
    private var calendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: MASpacing.xs) {
            ForEach(viewModel.daysInMonth, id: \.self) { date in
                if let date = date {
                    dayCell(for: date)
                        .onTapGesture {
                            selectedDate = date
                            showDayDetail = true
                        }
                } else {
                    Color.clear
                        .frame(height: 44)
                }
            }
        }
    }
    
    private func dayCell(for date: Date) -> some View {
        let isToday = Calendar.current.isDateInToday(date)
        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
        let log = viewModel.log(for: date)
        let isPeriod = log?.isPeriodDay ?? false
        let prediction = viewModel.prediction(for: date)
        
        return ZStack {
            // Background
            if isSelected {
                Circle()
                    .fill(Color.accentGreenDark)
            } else if isPeriod {
                Circle()
                    .fill(Color.cycleMenstrual)
            } else if prediction != nil {
                Circle()
                    .stroke(Color.cycleMenstrual.opacity(0.5), lineWidth: 2)
            } else if isToday {
                Circle()
                    .stroke(Color.accentGreenDark, lineWidth: 2)
            }
            
            VStack(spacing: 2) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(MAFont.bodyMedium)
                    .foregroundColor(textColor(isSelected: isSelected, isPeriod: isPeriod, isToday: isToday))
                
                // Indicator dots
                if log != nil && !isPeriod {
                    Circle()
                        .fill(Color.accentGreenLight)
                        .frame(width: 4, height: 4)
                }
            }
        }
        .frame(height: 44)
    }
    
    private func textColor(isSelected: Bool, isPeriod: Bool, isToday: Bool) -> Color {
        if isSelected || isPeriod {
            return .textInverse
        }
        return .textPrimary
    }
    
    // MARK: - Selected Day Info
    private var selectedDayInfo: some View {
        VStack(alignment: .leading, spacing: MASpacing.md) {
            HStack {
                Text(viewModel.formattedDate(selectedDate))
                    .font(MAFont.titleMedium)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                if let log = viewModel.log(for: selectedDate) {
                    if log.isPeriodDay {
                        MAStatusBadge(status: log.periodFlow?.displayName ?? "Period", color: .cycleMenstrual)
                    }
                }
            }
            
            if let log = viewModel.log(for: selectedDate) {
                if !log.symptoms.isEmpty {
                    FlowLayout(spacing: MASpacing.xs) {
                        ForEach(log.symptoms, id: \.self) { symptom in
                            MATag(symptom.displayName, color: .surfaceContrast)
                        }
                    }
                }
                
                if let mood = log.mood {
                    HStack(spacing: MASpacing.xs) {
                        Text(mood.emoji)
                        Text(mood.displayName)
                            .font(MAFont.bodyMedium)
                            .foregroundColor(.textSecondary)
                    }
                }
            } else {
                Text("No data logged")
                    .font(MAFont.bodyMedium)
                    .foregroundColor(.textTertiary)
            }
        }
        .padding(MASpacing.lg)
        .background(Color.surfaceContrast.opacity(0.3))
        .cornerRadius(MACornerRadius.medium)
    }
}

// MARK: - Day Detail View
struct DayDetailView: View {
    let date: Date
    @Binding var isPresented: Bool
    @StateObject private var viewModel = QuickLogViewModel()
    
    var body: some View {
        QuickLogView(isPresented: $isPresented)
    }
}

#Preview {
    CycleCalendarView()
}
