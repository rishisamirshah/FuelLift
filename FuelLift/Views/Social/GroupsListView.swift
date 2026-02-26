import SwiftUI

struct GroupsListView: View {
    @StateObject private var viewModel = SocialViewModel()
    @State private var showCreateGroup = false
    @State private var showJoinGroup = false

    var body: some View {
        NavigationStack {
            List {
                if viewModel.groups.isEmpty && !viewModel.isLoading {
                    Section {
                        VStack(spacing: 12) {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)
                            Text("No groups yet")
                                .font(.headline)
                            Text("Create or join a group to track progress with friends.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    }
                }

                Section {
                    ForEach(viewModel.groups.indices, id: \.self) { index in
                        let group = viewModel.groups[index]
                        NavigationLink {
                            GroupDetailView(groupData: group)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(group["name"] as? String ?? "Group")
                                    .font(.subheadline.bold())
                                let memberCount = (group["memberIds"] as? [String])?.count ?? 0
                                Text("\(memberCount) members")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
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
            Form {
                TextField("Group Name", text: $name)
                TextField("Description", text: $description, axis: .vertical)
                    .lineLimit(3...6)
            }
            .navigationTitle("Create Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create") {
                        Task {
                            await viewModel.createGroup(name: name, description: description)
                            dismiss()
                        }
                    }
                    .bold()
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
            Form {
                Section {
                    TextField("Group ID or Invite Code", text: $groupId)
                } footer: {
                    Text("Ask a group member for the invite code.")
                }
            }
            .navigationTitle("Join Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Join") {
                        Task {
                            await viewModel.joinGroup(id: groupId)
                            dismiss()
                        }
                    }
                    .bold()
                    .disabled(groupId.isEmpty)
                }
            }
        }
    }
}
