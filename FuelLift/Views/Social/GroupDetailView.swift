import SwiftUI

struct GroupDetailView: View {
    let groupData: [String: Any]

    private var groupName: String { groupData["name"] as? String ?? "Group" }
    private var groupDesc: String { groupData["description"] as? String ?? "" }
    private var memberIds: [String] { groupData["memberIds"] as? [String] ?? [] }
    private var groupId: String { groupData["id"] as? String ?? "" }

    @State private var copiedCode = false

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingLG) {
                // Group header
                VStack(spacing: Theme.spacingMD) {
                    ZStack {
                        Circle()
                            .fill(Color.appAccent.opacity(0.15))
                            .frame(width: 64, height: 64)
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.appAccent)
                    }

                    Text(groupName)
                        .font(.system(size: Theme.headlineSize, weight: .bold))
                        .foregroundStyle(Color.appTextPrimary)

                    if !groupDesc.isEmpty {
                        Text(groupDesc)
                            .font(.system(size: Theme.bodySize))
                            .foregroundStyle(Color.appTextSecondary)
                            .multilineTextAlignment(.center)
                    }

                    Text("\(memberIds.count) members")
                        .font(.system(size: Theme.captionSize))
                        .foregroundStyle(Color.appTextTertiary)
                }
                .frame(maxWidth: .infinity)
                .cardStyle()

                // Leaderboard preview
                VStack(spacing: Theme.spacingMD) {
                    HStack {
                        Text("Leaderboard")
                            .sectionHeaderStyle()
                        Spacer()
                        NavigationLink {
                            LeaderboardView(groupId: groupId)
                        } label: {
                            Text("View All")
                                .font(.system(size: Theme.captionSize, weight: .semibold))
                                .foregroundStyle(Color.appAccent)
                        }
                    }

                    NavigationLink {
                        LeaderboardView(groupId: groupId)
                    } label: {
                        HStack(spacing: Theme.spacingMD) {
                            Image(systemName: "trophy.fill")
                                .font(.title2)
                                .foregroundStyle(Color.yellow)
                            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                                Text("View Leaderboard")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(Color.appTextPrimary)
                                Text("See who's on top this week")
                                    .font(.system(size: Theme.captionSize))
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(Color.appTextTertiary)
                        }
                        .secondaryCardStyle()
                    }
                    .buttonStyle(.plain)
                }
                .cardStyle()

                // Members
                VStack(spacing: Theme.spacingMD) {
                    Text("Members")
                        .sectionHeaderStyle()

                    ForEach(memberIds, id: \.self) { memberId in
                        HStack(spacing: Theme.spacingMD) {
                            ZStack {
                                Circle()
                                    .fill(Color.appCardSecondary)
                                    .frame(width: 36, height: 36)
                                Image(systemName: "person.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(Color.appTextTertiary)
                            }
                            Text(memberId.prefix(8) + "...")
                                .font(.subheadline)
                                .foregroundStyle(Color.appTextPrimary)
                            Spacer()
                        }
                    }
                }
                .cardStyle()

                // Invite
                VStack(spacing: Theme.spacingMD) {
                    Text("Invite Friends")
                        .sectionHeaderStyle()

                    Button {
                        UIPasteboard.general.string = groupId
                        copiedCode = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            copiedCode = false
                        }
                    } label: {
                        HStack {
                            Image(systemName: copiedCode ? "checkmark.circle.fill" : "doc.on.doc")
                                .foregroundStyle(copiedCode ? Color.appCaloriesColor : Color.appAccent)
                            Text(copiedCode ? "Copied!" : "Copy Invite Code")
                                .font(.subheadline.bold())
                                .foregroundStyle(Color.appTextPrimary)
                            Spacer()
                        }
                        .secondaryCardStyle()
                    }
                    .buttonStyle(.plain)
                }
                .cardStyle()
            }
            .padding(.horizontal, Theme.spacingLG)
            .padding(.vertical, Theme.spacingSM)
        }
        .screenBackground()
        .navigationTitle(groupName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
