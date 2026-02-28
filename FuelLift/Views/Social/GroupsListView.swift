import SwiftUI

struct GroupsListView: View {
    @StateObject private var viewModel = SocialViewModel()
    @State private var showCreateGroup = false
    @State private var showJoinGroup = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacingLG) {
                    if viewModel.groups.isEmpty && !viewModel.isLoading {
                        // Empty state
                        VStack(spacing: Theme.spacingLG) {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(Color.appTextTertiary)

                            Text("No groups yet")
                                .font(.system(size: Theme.headlineSize, weight: .bold))
                                .foregroundStyle(Color.appTextPrimary)

                            Text("Create or join a group to track progress with friends.")
                                .font(.system(size: Theme.bodySize))
                                .foregroundStyle(Color.appTextSecondary)
                                .multilineTextAlignment(.center)

                            HStack(spacing: Theme.spacingMD) {
                                Button {
                                    showCreateGroup = true
                                } label: {
                                    Label("Create", systemImage: "plus.circle.fill")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(Theme.spacingMD)
                                        .background(Color.appAccent)
                                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                                }

                                Button {
                                    showJoinGroup = true
                                } label: {
                                    Label("Join", systemImage: "person.badge.plus")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(Color.appAccent)
                                        .frame(maxWidth: .infinity)
                                        .padding(Theme.spacingMD)
                                        .background(Color.appCardBackground)
                                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                                }
                            }
                        }
                        .cardStyle()
                        .padding(.top, Theme.spacingXL)
                    }

                    // Group cards
                    ForEach(viewModel.groups.indices, id: \.self) { index in
                        let group = viewModel.groups[index]
                        NavigationLink {
                            GroupDetailView(groupData: group)
                        } label: {
                            HStack(spacing: Theme.spacingMD) {
                                ZStack {
                                    Circle()
                                        .fill(Color.appAccent.opacity(0.15))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "person.3.fill")
                                        .font(.system(size: Theme.inlineIconSize))
                                        .foregroundStyle(Color.appAccent)
                                }

                                VStack(alignment: .leading, spacing: Theme.spacingXS) {
                                    Text(group["name"] as? String ?? "Group")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(Color.appTextPrimary)
                                    let memberCount = (group["memberIds"] as? [String])?.count ?? 0
                                    Text("\(memberCount) members")
                                        .font(.system(size: Theme.captionSize))
                                        .foregroundStyle(Color.appTextSecondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(Color.appTextTertiary)
                            }
                            .cardStyle()
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Theme.spacingLG)
            }
            .screenBackground()
            .navigationTitle("Social")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button { showCreateGroup = true } label: {
                            Label("Create Group", systemImage: "plus.circle")
                        }
                        Button { showJoinGroup = true } label: {
                            Label("Join Group", systemImage: "person.badge.plus")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.appAccent)
                    }
                }
            }
            .refreshable {
                await viewModel.loadGroups()
            }
            .task {
                await viewModel.loadGroups()
            }
            .sheet(isPresented: $showCreateGroup) {
                CreateGroupSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showJoinGroup) {
                JoinGroupSheet(viewModel: viewModel)
            }
        }
    }
}

struct CreateGroupSheet: View {
    @ObservedObject var viewModel: SocialViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.spacingXL) {
                VStack(spacing: Theme.spacingLG) {
                    ThemedField(label: "Group Name", text: $name, placeholder: "e.g. Gym Bros")
                    ThemedField(label: "Description", text: $description, placeholder: "What's this group about?")
                }
                .cardStyle()

                Spacer()
            }
            .padding(.horizontal, Theme.spacingLG)
            .padding(.top, Theme.spacingLG)
            .screenBackground()
            .navigationTitle("Create Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.appTextSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create") {
                        Task {
                            await viewModel.createGroup(name: name, description: description)
                            dismiss()
                        }
                    }
                    .bold()
                    .foregroundStyle(Color.appAccent)
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

struct JoinGroupSheet: View {
    @ObservedObject var viewModel: SocialViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var groupId = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.spacingXL) {
                VStack(spacing: Theme.spacingSM) {
                    ThemedField(label: "Group ID or Invite Code", text: $groupId, placeholder: "Paste code here")

                    Text("Ask a group member for the invite code.")
                        .font(.system(size: Theme.captionSize))
                        .foregroundStyle(Color.appTextTertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .cardStyle()

                Spacer()
            }
            .padding(.horizontal, Theme.spacingLG)
            .padding(.top, Theme.spacingLG)
            .screenBackground()
            .navigationTitle("Join Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.appTextSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Join") {
                        Task {
                            await viewModel.joinGroup(id: groupId)
                            dismiss()
                        }
                    }
                    .bold()
                    .foregroundStyle(Color.appAccent)
                    .disabled(groupId.isEmpty)
                }
            }
        }
    }
}
