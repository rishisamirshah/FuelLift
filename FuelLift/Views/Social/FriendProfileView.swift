import SwiftUI

struct FriendProfileView: View {
    let friendData: [String: Any]

    private var name: String { friendData["displayName"] as? String ?? "Friend" }
    private var streak: Int { friendData["currentStreak"] as? Int ?? 0 }
    private var workoutsThisWeek: Int { friendData["workoutsThisWeek"] as? Int ?? 0 }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile header
                VStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.secondary)

                    Text(name)
                        .font(.title2.bold())

                    HStack(spacing: 24) {
                        statBadge(icon: "flame.fill", value: "\(streak)", label: "Streak", color: .orange)
                        statBadge(icon: "dumbbell.fill", value: "\(workoutsThisWeek)", label: "This Week", color: .blue)
                    }
                }
                .padding(.top, 20)

                // Shared workouts would go here
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Activity")
                        .font(.headline)
                    Text("Shared workouts and meals will appear here.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardStyle()
                .padding(.horizontal)
            }
        }
        .navigationTitle(name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func statBadge(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(value)
                .font(.title3.bold())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
