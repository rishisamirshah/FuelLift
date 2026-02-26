import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    private init() {}

    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    // MARK: - User Profile

    func createUserProfile(_ data: [String: Any]) async throws {
        guard let uid = currentUserId else { throw AuthError.noCurrentUser }
        var profileData = data
        profileData["createdAt"] = FieldValue.serverTimestamp()
        profileData["updatedAt"] = FieldValue.serverTimestamp()
        try await db.collection(AppConstants.Collections.users).document(uid).setData(profileData)
    }

    func fetchUserProfile(userId: String) async throws -> [String: Any]? {
        let doc = try await db.collection(AppConstants.Collections.users).document(userId).getDocument()
        return doc.data()
    }

    func updateUserProfile(_ fields: [String: Any]) async throws {
        guard let uid = currentUserId else { throw AuthError.noCurrentUser }
        var data = fields
        data["updatedAt"] = FieldValue.serverTimestamp()
        try await db.collection(AppConstants.Collections.users).document(uid).updateData(data)
    }

    // MARK: - FCM Token

    func updateFCMToken(_ token: String) async {
        guard let uid = currentUserId else { return }
        try? await db.collection(AppConstants.Collections.users).document(uid).updateData([
            "fcmToken": token
        ])
    }

    // MARK: - Food Entries

    func saveFoodEntry(_ data: [String: Any]) async throws -> String {
        guard let uid = currentUserId else { throw AuthError.noCurrentUser }
        var entryData = data
        entryData["userId"] = uid
        entryData["createdAt"] = FieldValue.serverTimestamp()
        let ref = try await db.collection(AppConstants.Collections.foodEntries).addDocument(data: entryData)
        return ref.documentID
    }

    func fetchFoodEntries(for date: Date) async throws -> [[String: Any]] {
        guard let uid = currentUserId else { throw AuthError.noCurrentUser }
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let snapshot = try await db.collection(AppConstants.Collections.foodEntries)
            .whereField("userId", isEqualTo: uid)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .order(by: "date", descending: false)
            .getDocuments()

        return snapshot.documents.map { doc in
            var data = doc.data()
            data["id"] = doc.documentID
            return data
        }
    }

    func deleteFoodEntry(id: String) async throws {
        try await db.collection(AppConstants.Collections.foodEntries).document(id).delete()
    }

    // MARK: - Workouts

    func saveWorkout(_ data: [String: Any]) async throws -> String {
        guard let uid = currentUserId else { throw AuthError.noCurrentUser }
        var workoutData = data
        workoutData["userId"] = uid
        workoutData["createdAt"] = FieldValue.serverTimestamp()
        let ref = try await db.collection(AppConstants.Collections.workouts).addDocument(data: workoutData)
        return ref.documentID
    }

    func fetchWorkouts(limit: Int = 50) async throws -> [[String: Any]] {
        guard let uid = currentUserId else { throw AuthError.noCurrentUser }

        let snapshot = try await db.collection(AppConstants.Collections.workouts)
            .whereField("userId", isEqualTo: uid)
            .order(by: "date", descending: true)
            .limit(to: limit)
            .getDocuments()

        return snapshot.documents.map { doc in
            var data = doc.data()
            data["id"] = doc.documentID
            return data
        }
    }

    // MARK: - Groups

    func createGroup(name: String, description: String) async throws -> String {
        guard let uid = currentUserId else { throw AuthError.noCurrentUser }
        let data: [String: Any] = [
            "name": name,
            "description": description,
            "creatorId": uid,
            "memberIds": [uid],
            "createdAt": FieldValue.serverTimestamp()
        ]
        let ref = try await db.collection(AppConstants.Collections.groups).addDocument(data: data)
        return ref.documentID
    }

    func fetchUserGroups() async throws -> [[String: Any]] {
        guard let uid = currentUserId else { throw AuthError.noCurrentUser }

        let snapshot = try await db.collection(AppConstants.Collections.groups)
            .whereField("memberIds", arrayContains: uid)
            .getDocuments()

        return snapshot.documents.map { doc in
            var data = doc.data()
            data["id"] = doc.documentID
            return data
        }
    }

    func joinGroup(groupId: String) async throws {
        guard let uid = currentUserId else { throw AuthError.noCurrentUser }
        try await db.collection(AppConstants.Collections.groups).document(groupId).updateData([
            "memberIds": FieldValue.arrayUnion([uid])
        ])
    }

    // MARK: - Friends

    func sendFriendRequest(toUserId: String) async throws {
        guard let uid = currentUserId else { throw AuthError.noCurrentUser }
        let data: [String: Any] = [
            "fromUserId": uid,
            "toUserId": toUserId,
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp()
        ]
        try await db.collection(AppConstants.Collections.friendships).addDocument(data: data)
    }

    func fetchFriends() async throws -> [[String: Any]] {
        guard let uid = currentUserId else { throw AuthError.noCurrentUser }

        let sentSnapshot = try await db.collection(AppConstants.Collections.friendships)
            .whereField("fromUserId", isEqualTo: uid)
            .whereField("status", isEqualTo: "accepted")
            .getDocuments()

        let receivedSnapshot = try await db.collection(AppConstants.Collections.friendships)
            .whereField("toUserId", isEqualTo: uid)
            .whereField("status", isEqualTo: "accepted")
            .getDocuments()

        let all = sentSnapshot.documents + receivedSnapshot.documents
        return all.map { doc in
            var data = doc.data()
            data["id"] = doc.documentID
            return data
        }
    }
}
