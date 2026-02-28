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
            .padding(.horizontal, Theme.spacingLG)
            .padding(.vertical, Theme.spacingMD)

            ScrollView {
                VStack(spacing: Theme.spacingMD) {
                    ForEach(sampleData, id: \.name) { entry in
                        HStack(spacing: Theme.spacingMD) {
                            // Rank badge
                            ZStack {
                                Circle()
                                    .fill(rankColor(entry.rank))
                                    .frame(width: 36, height: 36)
                                Text("\(entry.rank)")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.white)
                            }

                            // Avatar placeholder
                            ZStack {
                                Circle()
                                    .fill(Color.appCardSecondary)
                                    .frame(width: 40, height: 40)
                                Image(systemName: "person.fill")
                                    .foregroundStyle(Color.appTextTertiary)
                            }

                            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                                Text(entry.name)
                                    .font(.subheadline.bold())
                                    .foregroundStyle(Color.appTextPrimary)
                                if entry.rank == 1 {
                                    Text("Leader")
                                        .font(.system(size: Theme.miniSize, weight: .semibold))
                                        .foregroundStyle(Color.yellow)
                                }
                            }

                            Spacer()

                            Text(entry.value)
                                .font(.subheadline.bold())
                                .foregroundStyle(Color.appAccent)
                        }
                        .cardStyle()
                    }
                }
                .padding(.horizontal, Theme.spacingLG)
                .padding(.bottom, Theme.spacingLG)
            }
        }
        .screenBackground()
        .navigationTitle("Leaderboard")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return Color(UIColor.systemGray4)
        }
    }
}
