import SwiftUI

struct WeekDaySelector: View {
    @Binding var selectedDate: Date
    var loggedDates: Set<Date> = []

    private var weekDays: [DayItem] {
        let calendar = Calendar.current
        let today = Date()
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else { return [] }

        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: weekInterval.start) else { return nil }
            let dayName = date.formatted(.dateTime.weekday(.abbreviated)).uppercased()
            let dayNumber = calendar.component(.day, from: date)
            let isLogged = loggedDates.contains(where: { calendar.isDate($0, inSameDayAs: date) })
            let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
            let isToday = calendar.isDateInToday(date)
            return DayItem(date: date, dayName: dayName, dayNumber: dayNumber, isLogged: isLogged, isSelected: isSelected, isToday: isToday)
        }
    }

    var body: some View {
        HStack(spacing: Theme.spacingSM) {
            ForEach(weekDays) { day in
                DayBadge(day: day)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedDate = day.date
                        }
                    }
            }
        }
    }
}

// MARK: - Day Item

private struct DayItem: Identifiable {
    let id = UUID()
    let date: Date
    let dayName: String
    let dayNumber: Int
    let isLogged: Bool
    let isSelected: Bool
    let isToday: Bool
}

// MARK: - Day Badge

private struct DayBadge: View {
    let day: DayItem

    var body: some View {
        VStack(spacing: Theme.spacingXS) {
            Text(day.dayName)
                .font(.system(size: Theme.miniSize, weight: .medium))
                .foregroundStyle(day.isSelected ? Color.appTextPrimary : Color.appTextSecondary)

            ZStack {
                Circle()
                    .fill(day.isSelected ? Color.appAccent : (day.isLogged ? Color.appAccent.opacity(0.3) : Color.clear))
                    .frame(width: 36, height: 36)

                if day.isToday && !day.isSelected {
                    Circle()
                        .stroke(Color.appAccent, lineWidth: 2)
                        .frame(width: 36, height: 36)
                }

                Text("\(day.dayNumber)")
                    .font(.system(size: Theme.bodySize, weight: day.isSelected ? .bold : .medium, design: .rounded))
                    .foregroundStyle(day.isSelected ? .white : Color.appTextPrimary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    WeekDaySelector(selectedDate: .constant(Date()))
        .padding()
        .background(Color.appBackground)
}
