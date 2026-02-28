import SwiftUI
import Charts

struct NutritionChartView: View {
    let data: [(date: Date, calories: Int)]

    @State private var selectedWeek: WeekFilter = .thisWeek

    private var averageCalories: Int {
        let weekData = filteredData
        guard !weekData.isEmpty else { return 0 }
        return weekData.reduce(0) { $0 + $1.calories } / weekData.count
    }

    private var previousAverage: Int {
        let prevData = dataForWeek(offset: -1)
        guard !prevData.isEmpty else { return 0 }
        return prevData.reduce(0) { $0 + $1.calories } / prevData.count
    }

    private var percentChange: Int {
        guard previousAverage > 0 else { return 0 }
        return Int(((Double(averageCalories) - Double(previousAverage)) / Double(previousAverage)) * 100)
    }

    private var filteredData: [(date: Date, calories: Int)] {
        let offset = selectedWeek == .thisWeek ? 0 : -1
        return dataForWeek(offset: offset)
    }

    private func dataForWeek(offset: Int) -> [(date: Date, calories: Int)] {
        let calendar = Calendar.current
        let today = Date()
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else { return [] }
        let weekStart = calendar.date(byAdding: .weekOfYear, value: offset, to: weekInterval.start) ?? today
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? today
        return data.filter { $0.date >= weekStart && $0.date < weekEnd }
    }

    // Generate stacked data for protein/carbs/fat estimation
    private var stackedData: [NutrientDay] {
        let calendar = Calendar.current
        let offset = selectedWeek == .thisWeek ? 0 : -1
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return [] }
        let weekStart = calendar.date(byAdding: .weekOfYear, value: offset, to: weekInterval.start) ?? Date()

        return (0..<7).map { dayOffset in
            let day = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) ?? Date()
            let dayStart = calendar.startOfDay(for: day)
            let cals = data
                .filter { calendar.isDate($0.date, inSameDayAs: dayStart) }
                .reduce(0) { $0 + $1.calories }

            // Estimate macros from calories (roughly 30/40/30 P/C/F)
            let protein = Int(Double(cals) * 0.30 / 4.0) // grams * 4 cal
            let carbs = Int(Double(cals) * 0.40 / 4.0)
            let fat = Int(Double(cals) * 0.30 / 9.0)

            return NutrientDay(
                dayLabel: day.dayOfWeek,
                proteinCals: protein * 4,
                carbsCals: carbs * 4,
                fatCals: fat * 9
            )
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            // Header
            Text("Daily Average Calories")
                .font(.system(size: Theme.subheadlineSize, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)

            // Big number + change
            HStack(alignment: .firstTextBaseline, spacing: Theme.spacingSM) {
                Text("\(averageCalories.formattedWithComma)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)

                Text("cals")
                    .font(.system(size: Theme.captionSize))
                    .foregroundStyle(Color.appTextSecondary)

                if percentChange != 0 {
                    HStack(spacing: 2) {
                        Image(systemName: percentChange > 0 ? "arrow.up" : "arrow.down")
                            .font(.system(size: 10, weight: .bold))
                        Text("\(abs(percentChange))%")
                            .font(.system(size: Theme.captionSize, weight: .semibold))
                    }
                    .foregroundStyle(percentChange > 0 ? Color.appFatColor : Color.appCaloriesColor)
                }
            }

            // Stacked bar chart
            if stackedData.contains(where: { $0.total > 0 }) {
                Chart {
                    ForEach(stackedData) { day in
                        BarMark(
                            x: .value("Day", day.dayLabel),
                            y: .value("Cal", day.proteinCals)
                        )
                        .foregroundStyle(Color.appProteinColor)
                        .position(by: .value("Macro", "Protein"))

                        BarMark(
                            x: .value("Day", day.dayLabel),
                            y: .value("Cal", day.carbsCals)
                        )
                        .foregroundStyle(Color.appCarbsColor)
                        .position(by: .value("Macro", "Carbs"))

                        BarMark(
                            x: .value("Day", day.dayLabel),
                            y: .value("Cal", day.fatCals)
                        )
                        .foregroundStyle(Color.appFatColor)
                        .position(by: .value("Macro", "Fats"))
                    }
                }
                .chartForegroundStyleScale([
                    "Protein": Color.appProteinColor,
                    "Carbs": Color.appCarbsColor,
                    "Fats": Color.appFatColor
                ])
                .chartLegend(position: .bottom, spacing: Theme.spacingSM) {
                    HStack(spacing: Theme.spacingLG) {
                        legendDot(color: Color.appProteinColor, label: "Protein")
                        legendDot(color: Color.appCarbsColor, label: "Carbs")
                        legendDot(color: Color.appFatColor, label: "Fats")
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                            .foregroundStyle(Color.appTextTertiary.opacity(0.3))
                        AxisValueLabel()
                            .foregroundStyle(Color.appTextTertiary)
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
                .frame(height: 200)
            } else {
                Text("Start logging meals to see your nutrition trend.")
                    .font(.system(size: Theme.captionSize))
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
            }

            // Week filter
            FilterPills(options: WeekFilter.allCases, selected: $selectedWeek)
        }
        .cardStyle()
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

private struct NutrientDay: Identifiable {
    let id = UUID()
    let dayLabel: String
    let proteinCals: Int
    let carbsCals: Int
    let fatCals: Int

    var total: Int { proteinCals + carbsCals + fatCals }
}
