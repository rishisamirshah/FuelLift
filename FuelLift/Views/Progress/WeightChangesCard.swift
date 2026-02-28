import SwiftUI

struct WeightChangesCard: View {
    let weightHistory: [(date: Date, weight: Double)]

    private func weightChange(days: Int) -> (value: Double, trend: TrendRow.TrendDirection) {
        guard let latest = weightHistory.last else {
            return (0, .noChange)
        }
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let earlier = weightHistory.last(where: { $0.date <= cutoff }) ?? weightHistory.first
        guard let earlier else { return (0, .noChange) }

        let diff = latest.weight - earlier.weight
        if abs(diff) < 0.05 {
            return (0, .noChange)
        }
        return (diff, diff > 0 ? .increase : .decrease)
    }

    private var maxAbsChange: Double {
        let periods = [3, 7, 14, 30, 90]
        let maxVal = periods.map { abs(weightChange(days: $0).value) }.max() ?? 5.0
        return max(maxVal, 0.5)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            Text("Weight Changes")
                .font(.system(size: Theme.subheadlineSize, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)

            VStack(spacing: 0) {
                let periods = [
                    (label: "3 day", days: 3),
                    (label: "7 day", days: 7),
                    (label: "14 day", days: 14),
                    (label: "30 day", days: 30),
                    (label: "90 day", days: 90),
                    (label: "All Time", days: 9999)
                ]

                ForEach(Array(periods.enumerated()), id: \.offset) { index, period in
                    let change = weightChange(days: period.days)
                    TrendRow(
                        label: period.label,
                        value: change.value,
                        unit: "lbs",
                        trend: change.trend,
                        maxAbsValue: maxAbsChange
                    )

                    if index < periods.count - 1 {
                        Divider()
                            .overlay(Color.appTextTertiary.opacity(0.3))
                    }
                }
            }
        }
        .cardStyle()
    }
}

#Preview {
    WeightChangesCard(weightHistory: [
        (Calendar.current.date(byAdding: .day, value: -100, to: Date())!, 192.0),
        (Calendar.current.date(byAdding: .day, value: -60, to: Date())!, 190.0),
        (Calendar.current.date(byAdding: .day, value: -30, to: Date())!, 189.0),
        (Calendar.current.date(byAdding: .day, value: -7, to: Date())!, 188.0),
        (Date(), 187.0)
    ])
    .padding()
    .background(Color.appBackground)
}
