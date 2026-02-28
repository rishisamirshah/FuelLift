import SwiftUI
import Charts

struct WeeklyEnergyCard: View {
    let calorieHistory: [(date: Date, calories: Int)]
    @State private var selectedWeek: WeekFilter = .thisWeek

    private var weekData: [DailyEnergy] {
        let calendar = Calendar.current
        let today = Date()
        let weekOffset: Int = selectedWeek == .thisWeek ? 0 : -1

        let startOfThisWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let weekStart = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: startOfThisWeek) ?? today
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? today

        let weekDays = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
        return weekDays.map { day in
            let dayStart = calendar.startOfDay(for: day)
            let consumed = calorieHistory
                .filter { calendar.isDate($0.date, inSameDayAs: dayStart) }
                .reduce(0) { $0 + $1.calories }

            // Estimate burned as ~1800 base + minor variation
            let burned = consumed > 0 ? Int(Double(consumed) * 0.45) : 0

            return DailyEnergy(
                date: dayStart,
                dayLabel: day < weekEnd ? day.dayOfWeek : "",
                consumed: consumed,
                burned: burned
            )
        }
    }

    private var totalBurned: Int { weekData.reduce(0) { $0 + $1.burned } }
    private var totalConsumed: Int { weekData.reduce(0) { $0 + $1.consumed } }
    private var energyBalance: Int { totalConsumed - totalBurned }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingLG) {
            Text("Weekly Energy")
                .font(.system(size: Theme.subheadlineSize, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)

            // Summary row
            HStack(spacing: Theme.spacingXXL) {
                energyStat(label: "Burned", value: totalBurned, color: Color.appFatColor)
                energyStat(label: "Consumed", value: totalConsumed, color: Color.appCaloriesColor)
                energyStat(
                    label: "Energy",
                    value: energyBalance,
                    color: energyBalance >= 0 ? Color.appCaloriesColor : Color.appFatColor,
                    showSign: true
                )
            }

            // Chart
            if weekData.contains(where: { $0.consumed > 0 || $0.burned > 0 }) {
                Chart {
                    ForEach(weekData) { day in
                        BarMark(
                            x: .value("Day", day.dayLabel),
                            y: .value("Cal", day.burned)
                        )
                        .foregroundStyle(Color.appFatColor)
                        .position(by: .value("Type", "Burned"))
                        .cornerRadius(3)

                        BarMark(
                            x: .value("Day", day.dayLabel),
                            y: .value("Cal", day.consumed)
                        )
                        .foregroundStyle(Color.appCaloriesColor)
                        .position(by: .value("Type", "Consumed"))
                        .cornerRadius(3)
                    }
                }
                .chartForegroundStyleScale([
                    "Burned": Color.appFatColor,
                    "Consumed": Color.appCaloriesColor
                ])
                .chartLegend(position: .bottom, spacing: Theme.spacingMD) {
                    HStack(spacing: Theme.spacingLG) {
                        legendDot(color: Color.appFatColor, label: "Burned")
                        legendDot(color: Color.appCaloriesColor, label: "Consumed")
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                            .foregroundStyle(Color.appTextTertiary.opacity(0.3))
                        AxisValueLabel()
                            .foregroundStyle(Color.appTextTertiary)
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
                .frame(height: 180)
            } else {
                Text("No energy data for this week yet.")
                    .font(.system(size: Theme.captionSize))
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
            }

            // Filter pills
            FilterPills(options: WeekFilter.allCases, selected: $selectedWeek)
        }
        .cardStyle()
    }

    private func energyStat(label: String, value: Int, color: Color, showSign: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: Theme.miniSize, weight: .medium))
                .foregroundStyle(Color.appTextSecondary)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(showSign && value >= 0 ? "+\(value.formattedWithComma)" : "\(value.formattedWithComma)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(color)

                Text("cal")
                    .font(.system(size: Theme.miniSize))
                    .foregroundStyle(Color.appTextTertiary)
            }
        }
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: Theme.miniSize))
                .foregroundStyle(Color.appTextSecondary)
        }
    }
}

private struct DailyEnergy: Identifiable {
    let id = UUID()
    let date: Date
    let dayLabel: String
    let consumed: Int
    let burned: Int
}

#Preview {
    WeeklyEnergyCard(calorieHistory: [
        (Calendar.current.date(byAdding: .day, value: -1, to: Date())!, 1800),
        (Calendar.current.date(byAdding: .day, value: -2, to: Date())!, 2100),
        (Date(), 1500)
    ])
    .padding()
    .background(Color.appBackground)
}
