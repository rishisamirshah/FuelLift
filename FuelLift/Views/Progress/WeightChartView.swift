import SwiftUI
import Charts

struct WeightChartView: View {
    let data: [(date: Date, weight: Double)]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Body Weight")
                .font(.headline)

            if data.count < 2 {
                Text("Log your weight in Body Measurements to see trends.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(height: 150)
            } else {
                Chart(data, id: \.date) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Weight", point.weight)
                    )
                    .foregroundStyle(.orange)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Weight", point.weight)
                    )
                    .foregroundStyle(.orange.opacity(0.1))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Weight", point.weight)
                    )
                    .foregroundStyle(.orange)
                    .symbolSize(30)
                }
                .frame(height: 180)
                .chartYScale(domain: .automatic(includesZero: false))
            }
        }
        .cardStyle()
    }
}
