import SwiftUI
import Charts

struct NutritionChartView: View {
    let data: [(date: Date, calories: Int)]

    var averageCalories: Int {
        guard !data.isEmpty else { return 0 }
        return data.reduce(0) { $0 + $1.calories } / data.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Calorie Trend")
                    .font(.headline)
                Spacer()
                Text("Avg: \(averageCalories) kcal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if data.isEmpty {
                Text("Start logging meals to see your calorie trend.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(height: 150)
            } else {
                Chart(data, id: \.date) { point in
                    BarMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Calories", point.calories)
                    )
                    .foregroundStyle(.appCalories.gradient)
                    .cornerRadius(4)

                    RuleMark(y: .value("Average", averageCalories))
                        .foregroundStyle(.orange)
                        .lineStyle(StrokeStyle(dash: [5, 5]))
                }
                .frame(height: 180)
            }
        }
        .cardStyle()
    }
}
