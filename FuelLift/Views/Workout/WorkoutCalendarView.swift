import SwiftUI

struct WorkoutCalendarView: View {
    let workoutDates: Set<Date>
    @Environment(\.dismiss) private var dismiss
    @State private var displayedMonth = Date()

    private let calendar = Calendar.current
    private let daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacingXXL) {
                    monthView(for: displayedMonth)
                }
                .padding(Theme.spacingLG)
            }
            .screenBackground()
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.appTextPrimary)
                    }
                }
            }
        }
    }

    // MARK: - Month View

    private func monthView(for date: Date) -> some View {
        VStack(spacing: Theme.spacingMD) {
            HStack {
                Button {
                    withAnimation {
                        displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                    }
                } label: {
                    Image("icon_chevron_right")
                        .resizable()
                        .renderingMode(.original)
                        .interpolation(.none)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .scaleEffect(x: -1, y: 1)
                }

                Spacer()

                Text(date, format: .dateTime.month(.wide).year())
                    .font(.system(size: Theme.headlineSize, weight: .bold))
                    .foregroundStyle(Color.appTextPrimary)

                Spacer()

                Button {
                    withAnimation {
                        displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                    }
                } label: {
                    Image("icon_chevron_right")
                        .resizable()
                        .renderingMode(.original)
                        .interpolation(.none)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.horizontal, Theme.spacingSM)

            // Day-of-week headers
            HStack(spacing: 0) {
                ForEach(daysOfWeek.indices, id: \.self) { i in
                    Text(daysOfWeek[i])
                        .font(.system(size: Theme.captionSize, weight: .semibold))
                        .foregroundStyle(Color.appTextTertiary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar grid
            let days = daysInMonth(for: date)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: Theme.spacingSM) {
                ForEach(days.indices, id: \.self) { index in
                    if let day = days[index] {
                        dayCell(day)
                    } else {
                        Color.clear.frame(height: 54)
                    }
                }
            }
        }
    }

    // MARK: - Day Cell

    private func dayCell(_ date: Date) -> some View {
        let isToday = calendar.isDateInToday(date)
        let hasWorkout = workoutDates.contains { calendar.isDate($0, inSameDayAs: date) }

        return VStack(spacing: 2) {
            ZStack {
                if isToday {
                    Circle()
                        .fill(Color.appTextPrimary)
                        .frame(width: 36, height: 36)
                } else if hasWorkout {
                    Circle()
                        .fill(Color.appCardSecondary)
                        .frame(width: 36, height: 36)
                }

                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: Theme.bodySize, weight: isToday ? .bold : .regular))
                    .foregroundStyle(isToday ? Color.appBackground : Color.appTextPrimary)
            }

            if hasWorkout {
                Image("icon_checkmark_circle")
                    .resizable()
                    .renderingMode(.original)
                    .interpolation(.none)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
            } else {
                Color.clear.frame(height: 18)
            }
        }
        .frame(height: 54)
    }

    // MARK: - Helpers

    private func daysInMonth(for date: Date) -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return []
        }

        // Convert to Monday-start: Mon=0, Tue=1, ..., Sun=6
        let weekday = (calendar.component(.weekday, from: firstDay) + 5) % 7

        var days: [Date?] = Array(repeating: nil, count: weekday)

        for day in range {
            if let d = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(d)
            }
        }

        return days
    }
}
