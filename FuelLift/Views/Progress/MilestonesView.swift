import SwiftUI
import SwiftData

struct MilestonesView: View {
    @Query private var profiles: [UserProfile]
    @Query private var badges: [Badge]
    @State private var appeared = false

    private var profile: UserProfile? { profiles.first }
    private var streakCount: Int { profile?.currentStreak ?? 0 }

    private let columns = [
        GridItem(.flexible(), spacing: Theme.spacingMD),
        GridItem(.flexible(), spacing: Theme.spacingMD),
        GridItem(.flexible(), spacing: Theme.spacingSM)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingXXL) {
                // Streak + badges earned header
                HStack(spacing: Theme.spacingLG) {
                    StreakBadge(count: streakCount, style: .expanded)

                    // Badges earned count
                    VStack(spacing: Theme.spacingSM) {
                        Image("icon_medal")
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 44, height: 44)

                        Text("\(earnedCount)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.appTextPrimary)

                        Text("Badges Earned")
                            .font(.system(size: Theme.captionSize, weight: .medium))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.spacingLG)
                    .background(Color.appCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
                }
                .padding(.horizontal, Theme.spacingLG)

                // Badge categories
                ForEach(Array(BadgeCategory.allCases.enumerated()), id: \.element) { index, category in
                    let categoryBadges = badgesForCategory(category)
                    if !categoryBadges.isEmpty {
                        VStack(alignment: .leading, spacing: Theme.spacingMD) {
                            Text(category.displayName)
                                .sectionHeaderStyle()
                                .padding(.horizontal, Theme.spacingLG)

                            LazyVGrid(columns: columns, spacing: Theme.spacingMD) {
                                ForEach(categoryBadges, id: \.key) { definition in
                                    let earned = isBadgeEarned(definition.key)
                                    BadgeGridItem(
                                        name: definition.name,
                                        iconName: definition.iconName,
                                        requirement: definition.requirement,
                                        isEarned: earned,
                                        imageName: definition.imageName,
                                        category: category
                                    )
                                }
                            }
                            .padding(.horizontal, Theme.spacingMD)
                        }
                        .cardStyle()
                        .padding(.horizontal, Theme.spacingLG)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(.easeOut(duration: 0.4).delay(Double(index) * 0.1), value: appeared)
                    }
                }
            }
            .padding(.vertical, Theme.spacingLG)
        }
        .screenBackground()
        .navigationTitle("Milestones")
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }

    private var earnedCount: Int {
        badges.filter { $0.isEarned }.count
    }

    private func badgesForCategory(_ category: BadgeCategory) -> [BadgeDefinition] {
        BadgeDefinition.all.filter { $0.category == category }
    }

    private func isBadgeEarned(_ key: BadgeKey) -> Bool {
        badges.first(where: { $0.key == key.rawValue })?.isEarned ?? false
    }
}

#Preview {
    NavigationStack {
        MilestonesView()
    }
}
