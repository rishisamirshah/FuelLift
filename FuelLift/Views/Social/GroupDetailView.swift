import SwiftUI

struct GroupDetailView: View {
    let groupData: [String: Any]

    private var groupName: String { groupData["name"] as? String ?? "Group" }
    private var groupDesc: String { groupData["description"] as? String ?? "" }
    private var memberIds: [String] { groupData["memberIds"] as? [String] ?? [] }
    private var groupId: String { groupData["id"] as? String ?? "" }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(groupName)
                        .font(.title2.bold())
                    if !groupDesc.isEmpty {
                        Text(groupDesc)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Text("\(memberIds.count) members")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Members") {
                ForEach(memberIds, id: \.self) { memberId in
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Text(memberId.prefix(8) + "...")
                            .font(.subheadline)
                        Spacer()
                    }
                }
            }

            Section("Leaderboard") {
                NavigationLink {
                    LeaderboardView(groupId: groupId)
                } label: {
                    Label("View Leaderboard", systemImage: "trophy")
                }
            }

            Section("Share") {
                Button {
                    UIPasteboard.general.string = groupId
                } label: {
                    Label("Copy Invite Code", systemImage: "doc.on.doc")
                }
            }
        }
        .navigationTitle(groupName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
