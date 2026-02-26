import SwiftUI

@MainActor
final class SocialViewModel: ObservableObject {
    @Published var groups: [[String: Any]] = []
    @Published var friends: [[String: Any]] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadGroups() async {
        isLoading = true
        do {
            groups = try await FirestoreService.shared.fetchUserGroups()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func createGroup(name: String, description: String) async {
        do {
            _ = try await FirestoreService.shared.createGroup(name: name, description: description)
            await loadGroups()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func joinGroup(id: String) async {
        do {
            try await FirestoreService.shared.joinGroup(groupId: id)
            await loadGroups()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadFriends() async {
        do {
            friends = try await FirestoreService.shared.fetchFriends()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
