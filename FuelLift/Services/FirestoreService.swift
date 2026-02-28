import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

final class FirestoreService {
    static let shared = FirestoreService()

    private var db: Firestore? {
        guard FirebaseApp.app() != nil else { return nil }
        return Firestore.firestore()
    }

    private init() {}

    private var currentUserId: String? {
        guard FirebaseApp.app() != nil else { return nil }
        return Auth.auth().currentUser?.uid
    }

    // MARK: - User Profile

    func createUserProfile(_ data: [String: Any]) async throws {
        guard let uid = currentUserId, let db else { return }
        var profileData = data
        profileData["createdAt"] = FieldValue.serverTimestamp()
        profileData["updatedAt"] = FieldValue.serverTimestamp()
        try await db.collection(AppConstants.Collections.users).document(uid).setData(profileData)
    }

    func fetchUserProfile(userId: String) async throws -> [String: Any]? {
        guard let db else { return nil }
        let doc = try await db.collection(AppConstants.Collections.users).document(userId).getDocument()
        return doc.data()
    }

    func updateUserProfile(_ fields: [String: Any]) async throws {
        guard let uid = currentUserId, let db else { return }
        var data = fields
        data["updatedAt"] = FieldValue.serverTimestamp()
        try await db.collection(AppConstants.Collections.users).document(uid).updateData(data)
    }

    // MARK: - FCM Token

    func updateFCMToken(_ token: String) async {
        guard let uid = currentUserId, let db else { return }
        try? await db.collection(AppConstants.Collections.users).document(uid).updateData([
            "fcmToken": token
        ])
    }

    // MARK: - Food Entries

    func saveFoodEntry(_ data: [String: Any]) async throws -> String {
        guard let uid = currentUserId, let db else { return "" }
        var entryData = data
        entryData["userId"] = uid
        entryData["createdAt"] = FieldValue.serverTimestamp()
        let ref = try await db.collection(AppConstants.Collections.foodEntries).addDocument(data: entryData)
        return ref.documentID
    }

    func fetchFoodEntries(for date: Date) async throws -> [[String: Any]] {
        guard let uid = currentUserId, let db else { return [] }
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
        guard let db else { return }
        try await db.collection(AppConstants.Collections.foodEntries).document(id).delete()
    }

    // MARK: - Workouts

    func saveWorkout(_ data: [String: Any]) async throws -> String {
        guard let uid = currentUserId, let db else { return "" }
        var workoutData = data
        workoutData["userId"] = uid
        workoutData["createdAt"] = FieldValue.serverTimestamp()
        let ref = try await db.collection(AppConstants.Collections.workouts).addDocument(data: workoutData)
        return ref.documentID
    }

    func fetchWorkouts(limit: Int = 50) async throws -> [[String: Any]] {
        guard let uid = currentUserId, let db else { return [] }

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
        guard let uid = currentUserId, let db else { return "" }
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
        guard let uid = currentUserId, let db else { return [] }

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
        guard let uid = currentUserId, let db else { return }
        try await db.collection(AppConstants.Collections.groups).document(groupId).updateData([
            "memberIds": FieldValue.arrayUnion([uid])
        ])
    }

    // MARK: - Friends

    func sendFriendRequest(toUserId: String) async throws {
        guard let uid = currentUserId, let db else { return }
        let data: [String: Any] = [
            "fromUserId": uid,
            "toUserId": toUserId,
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp()
        ]
        try await db.collection(AppConstants.Collections.friendships).addDocument(data: data)
    }

    func fetchFriends() async throws -> [[String: Any]] {
        guard let uid = currentUserId, let db else { return [] }

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
