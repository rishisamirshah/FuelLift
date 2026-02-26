import SwiftUI

struct LeaderboardView: View {
    let groupId: String
    @State private var selectedMetric = LeaderboardMetric.streak

    enum LeaderboardMetric: String, CaseIterable {
        case streak = "Streak"
        case calories = "Calories Hit"
        case workouts = "Workouts"
        case volume = "Volume"
    }

    // Placeholder data — in production, fetch from Firestore
    private let sampleData: [(name: String, value: String, rank: Int)] = [
        ("You", "12 days", 1),
        ("Alex M.", "9 days", 2),
        ("Jordan K.", "7 days", 3),
        ("Sam W.", "5 days", 4),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Picker("Metric", selection: $selectedMetric) {
                ForEach(LeaderboardMetric.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            List(sampleData, id: \.name) { entry in
                HStack {
                    // Rank
                    ZStack {
                        Circle()
                            .fill(rankColor(entry.rank))
                            .frame(width: 32, height: 32)
                        Text("\(entry.rank)")
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                    }

                    Text(entry.name)
                        .font(.subheadline)

                    Spacer()

                    Text(entry.value)
                        .font(.subheadline.bold())
                        .foregroundStyle(.orange)
                }
            }
        }
        .navigationTitle("Leaderboard")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .brown
        default: return Color(.systemGray4)
        }
    }
}
