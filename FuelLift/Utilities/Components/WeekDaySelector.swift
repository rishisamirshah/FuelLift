import SwiftUI

struct WeekDaySelector: View {
    @Binding var selectedDate: Date
    var loggedDates: Set<Date> = []

    private let totalDays = 21  // 3 weeks back from today

    private var days: [DayItem] {
        let calendar = Calendar.current
        let today = Date().startOfDay
        return (0..<totalDays).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -(totalDays - 1 - offset), to: today) else { return nil }
            let dayName = date.formatted(.dateTime.weekday(.abbreviated)).uppercased()
            let dayNumber = calendar.component(.day, from: date)
            let isLogged = loggedDates.contains(where: { calendar.isDate($0, inSameDayAs: date) })
            let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
            let isToday = calendar.isDateInToday(date)
            let isFirstOfMonth = dayNumber == 1 || offset == 0
            let monthLabel = isFirstOfMonth ? date.formatted(.dateTime.month(.abbreviated)).uppercased() : nil
            return DayItem(date: date, dayName: dayName, dayNumber: dayNumber, isLogged: isLogged, isSelected: isSelected, isToday: isToday, monthLabel: monthLabel)
        }
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.spacingSM) {
                    ForEach(days) { day in
                        VStack(spacing: 0) {
                            if let month = day.monthLabel {
                                Text(month)
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(Color.appAccent)
                                    .frame(height: 14)
                            } else {
                                Spacer().frame(height: 14)
                            }
                            DayBadge(day: day)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedDate = day.date
                                    }
                                }
                        }
                        .id(day.date.startOfDay)
                    }
                }
                .padding(.horizontal, Theme.spacingSM)
            }
            .onAppear {
                proxy.scrollTo(selectedDate.startOfDay, anchor: .center)
            }
            .onChange(of: selectedDate) { _, newDate in
                withAnimation {
                    proxy.scrollTo(newDate.startOfDay, anchor: .center)
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
    let monthLabel: String?
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
        .frame(width: 44)
    }
}

#Preview {
    WeekDaySelector(selectedDate: .constant(Date()))
        .padding()
        .background(Color.appBackground)
}
