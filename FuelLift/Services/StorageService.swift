import Foundation
import FirebaseCore
import FirebaseStorage
import FirebaseAuth

final class StorageService {
    static let shared = StorageService()

    private init() {}

    private var currentUserId: String? {
        guard FirebaseApp.app() != nil else { return nil }
        return Auth.auth().currentUser?.uid
    }

    func uploadProgressPhoto(imageData: Data) async throws -> String {
        guard let uid = currentUserId else { throw AuthError.noCurrentUser }
        let storage = Storage.storage()
        let path = "users/\(uid)/progress/\(UUID().uuidString).jpg"
        let ref = storage.reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await ref.putDataAsync(imageData, metadata: metadata)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }

    func uploadFoodPhoto(imageData: Data) async throws -> String {
        guard let uid = currentUserId else { throw AuthError.noCurrentUser }
        let storage = Storage.storage()
        let path = "users/\(uid)/food/\(UUID().uuidString).jpg"
        let ref = storage.reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await ref.putDataAsync(imageData, metadata: metadata)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
}
