import SwiftUI

struct StrengthChartView: View {
    let prs: [String: Double]

    var sortedPRs: [(name: String, e1rm: Double)] {
        prs.map { ($0.key, $0.value) }
            .sorted { $0.1 > $1.1 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Strength PRs (Est. 1RM)")
                .font(.headline)

            if prs.isEmpty {
                Text("Complete workouts to see your personal records.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 20)
            } else {
                ForEach(sortedPRs.prefix(10), id: \.name) { pr in
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.yellow)
                            .font(.caption)
                        Text(pr.name)
                            .font(.subheadline)
                        Spacer()
                        Text("\(pr.e1rm.oneDecimal) kg")
                            .font(.subheadline.bold())
                            .foregroundStyle(.orange)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .cardStyle()
    }
}
