import SwiftUI
import Charts

struct WeightChartView: View {
    let data: [(date: Date, weight: Double)]
    var goalPercent: Int = 0

    @State private var selectedFilter: TimeFilter = .ninetyDays

    private var filteredData: [(date: Date, weight: Double)] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -selectedFilter.days, to: Date()) ?? Date()
        return data.filter { $0.date >= cutoff }
    }

    private var weightDataLbs: [(date: Date, weight: Double)] {
        filteredData.map { ($0.date, $0.weight * 2.20462) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            // Header
            HStack {
                Text("Weight Progress")
                    .font(.system(size: Theme.subheadlineSize, weight: .bold))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                if goalPercent > 0 {
                    HStack(spacing: 4) {
                        Image("icon_flag")
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 12, height: 12)
                        Text("\(goalPercent)% of goal")
                            .font(.system(size: Theme.captionSize, weight: .semibold))
                    }
                    .foregroundStyle(Color.appCaloriesColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.appCaloriesColor.opacity(0.15))
                    .clipShape(Capsule())
                }
            }

            if weightDataLbs.count < 2 {
                Text("Log your weight to see trends.")
                    .font(.system(size: Theme.captionSize))
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
            } else {
                Chart(weightDataLbs, id: \.date) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Weight", point.weight)
                    )
                    .foregroundStyle(Color.appTextPrimary)
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 2))

                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Weight", point.weight)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.appTextPrimary.opacity(0.15), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Weight", point.weight)
                    )
                    .foregroundStyle(Color.appTextPrimary)
                    .symbolSize(20)
                }
                .chartYScale(domain: .automatic(includesZero: false))
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                            .foregroundStyle(Color.appTextTertiary.opacity(0.3))
                        AxisValueLabel()
                            .foregroundStyle(Color.appTextTertiary)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: max(weightDataLbs.count / 4, 7))) { value in
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                            .foregroundStyle(Color.appTextTertiary)
                    }
                }
                .frame(height: 180)
            }

            // Filter pills
            FilterPills(options: TimeFilter.allCases, selected: $selectedFilter)
        }
        .cardStyle()
    }
}
