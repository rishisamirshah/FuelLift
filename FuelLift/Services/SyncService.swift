import Foundation
import SwiftData

/// Handles syncing local SwiftData with Firestore.
/// On app launch, pulls latest from Firestore; on writes, pushes to Firestore.
final class SyncService {
    static let shared = SyncService()
    private init() {}

    /// Pull user profile from Firestore and update local SwiftData
    @MainActor
    func syncUserProfile(context: ModelContext) async {
        guard let uid = AuthService.shared.currentUser?.uid else { return }

        do {
            guard let remote = try await FirestoreService.shared.fetchUserProfile(userId: uid) else { return }

            let descriptor = FetchDescriptor<UserProfile>(
                predicate: #Predicate { $0.id == uid }
            )
            let existing = try? context.fetch(descriptor).first

            if let profile = existing {
                // Update local from remote
                profile.displayName = remote["displayName"] as? String ?? profile.displayName
                profile.calorieGoal = remote["calorieGoal"] as? Int ?? profile.calorieGoal
                profile.proteinGoal = remote["proteinGoal"] as? Int ?? profile.proteinGoal
                profile.carbsGoal = remote["carbsGoal"] as? Int ?? profile.carbsGoal
                profile.fatGoal = remote["fatGoal"] as? Int ?? profile.fatGoal
                profile.currentStreak = remote["currentStreak"] as? Int ?? profile.currentStreak
                profile.hasCompletedOnboarding = remote["hasCompletedOnboarding"] as? Bool ?? profile.hasCompletedOnboarding
                try? context.save()
            } else {
                // Create local from remote
                let profile = UserProfile(
                    id: uid,
                    displayName: remote["displayName"] as? String ?? "",
                    email: remote["email"] as? String ?? ""
                )
                profile.calorieGoal = remote["calorieGoal"] as? Int ?? AppConstants.defaultCalorieGoal
                profile.proteinGoal = remote["proteinGoal"] as? Int ?? AppConstants.defaultProteinGoal
                profile.carbsGoal = remote["carbsGoal"] as? Int ?? AppConstants.defaultCarbsGoal
                profile.fatGoal = remote["fatGoal"] as? Int ?? AppConstants.defaultFatGoal
                profile.hasCompletedOnboarding = remote["hasCompletedOnboarding"] as? Bool ?? false
                context.insert(profile)
                try? context.save()
            }
        } catch {
            print("Sync error: \(error)")
        }
    }
}
