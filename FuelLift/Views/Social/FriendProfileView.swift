import SwiftUI

struct FriendProfileView: View {
    let friendData: [String: Any]

    private var name: String { friendData["displayName"] as? String ?? "Friend" }
    private var streak: Int { friendData["currentStreak"] as? Int ?? 0 }
    private var workoutsThisWeek: Int { friendData["workoutsThisWeek"] as? Int ?? 0 }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingXL) {
                // Profile header
                VStack(spacing: Theme.spacingMD) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(Color.appTextSecondary)

                    Text(name)
                        .font(.system(size: Theme.headlineSize, weight: .bold))
                        .foregroundStyle(Color.appTextPrimary)

                    HStack(spacing: Theme.spacingXXL) {
                        statBadge(icon: "flame.fill", value: "\(streak)", label: "Streak", color: Color.appAccent)
                        statBadge(icon: "dumbbell.fill", value: "\(workoutsThisWeek)", label: "This Week", color: Color.appProteinColor)
                    }
                }
                .padding(.top, Theme.spacingXL)

                // Shared workouts would go here
                VStack(alignment: .leading, spacing: Theme.spacingSM) {
                    Text("Recent Activity")
                        .font(.system(size: Theme.subheadlineSize, weight: .bold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("Shared workouts and meals will appear here.")
                        .font(.system(size: Theme.captionSize))
                        .foregroundStyle(Color.appTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardStyle()
                .padding(.horizontal, Theme.spacingLG)
            }
        }
        .navigationTitle(name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func statBadge(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: Theme.spacingXS) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: Theme.subheadlineSize, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)
            Text(label)
                .font(.system(size: Theme.miniSize))
                .foregroundStyle(Color.appTextSecondary)
        }
    }
}
