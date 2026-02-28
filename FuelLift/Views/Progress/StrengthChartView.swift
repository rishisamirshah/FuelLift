import SwiftUI

struct StrengthChartView: View {
    let prs: [String: Double]

    var sortedPRs: [(name: String, e1rm: Double)] {
        prs.map { ($0.key, $0.value) }
            .sorted { $0.1 > $1.1 }
    }

    private var maxE1RM: Double {
        sortedPRs.first?.e1rm ?? 1
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacingLG) {
                Text("Strength PRs (Est. 1RM)")
                    .sectionHeaderStyle()
                    .padding(.horizontal, Theme.spacingLG)

                if prs.isEmpty {
                    VStack(spacing: Theme.spacingMD) {
                        Image(systemName: "trophy")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.appTextTertiary)
                        Text("Complete workouts to see your personal records.")
                            .font(.system(size: Theme.captionSize))
                            .foregroundStyle(Color.appTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.spacingHuge)
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(sortedPRs.prefix(15).enumerated()), id: \.element.name) { index, pr in
                            HStack(spacing: Theme.spacingMD) {
                                // Rank badge
                                ZStack {
                                    Circle()
                                        .fill(rankColor(index).opacity(0.15))
                                        .frame(width: 32, height: 32)
                                    Text("\(index + 1)")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundStyle(rankColor(index))
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(pr.name)
                                        .font(.system(size: Theme.bodySize, weight: .medium))
                                        .foregroundStyle(Color.appTextPrimary)
                                        .lineLimit(1)

                                    // Progress bar
                                    GeometryReader { geo in
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(Color.appPRColor.opacity(0.3))
                                            .frame(width: geo.size.width * CGFloat(pr.e1rm / maxE1RM))
                                            .frame(height: 4)
                                    }
                                    .frame(height: 4)
                                }

                                Spacer()

                                Text("\(pr.e1rm.oneDecimal) lbs")
                                    .font(.system(size: Theme.bodySize, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.appPRColor)
                            }
                            .padding(.vertical, Theme.spacingMD)
                            .padding(.horizontal, Theme.spacingLG)

                            if index < sortedPRs.prefix(15).count - 1 {
                                Divider()
                                    .overlay(Color.appTextTertiary.opacity(0.2))
                                    .padding(.horizontal, Theme.spacingLG)
                            }
                        }
                    }
                    .background(Color.appCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
                    .padding(.horizontal, Theme.spacingLG)
                }
            }
            .padding(.vertical, Theme.spacingLG)
        }
        .screenBackground()
        .navigationTitle("Strength PRs")
    }

    private func rankColor(_ index: Int) -> Color {
        switch index {
        case 0: return Color.appPRWeight  // gold
        case 1: return Color.appTextSecondary  // silver
        case 2: return Color.appPRColor  // bronze/teal
        default: return Color.appTextTertiary
        }
    }
}
