import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: String
    var displayName: String
    var email: String
    var photoURL: String?
    var createdAt: Date
    var updatedAt: Date

    // Goals
    var calorieGoal: Int
    var proteinGoal: Int
    var carbsGoal: Int
    var fatGoal: Int
    var waterGoalML: Int

    // Body stats
    var heightCM: Double?
    var weightKG: Double?
    var age: Int?
    var gender: String?
    var activityLevel: String?

    // Preferences
    var useMetricUnits: Bool
    var darkModeEnabled: Bool
    var notificationsEnabled: Bool
    var healthKitEnabled: Bool

    // Streaks
    var currentStreak: Int
    var longestStreak: Int
    var lastLogDate: Date?

    // Onboarding
    var hasCompletedOnboarding: Bool

    init(
        id: String,
        displayName: String = "",
        email: String = ""
    ) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.createdAt = Date()
        self.updatedAt = Date()
        self.calorieGoal = AppConstants.defaultCalorieGoal
        self.proteinGoal = AppConstants.defaultProteinGoal
        self.carbsGoal = AppConstants.defaultCarbsGoal
        self.fatGoal = AppConstants.defaultFatGoal
        self.waterGoalML = AppConstants.defaultWaterGoalML
        self.useMetricUnits = true
        self.darkModeEnabled = false
        self.notificationsEnabled = true
        self.healthKitEnabled = false
        self.currentStreak = 0
        self.longestStreak = 0
        self.hasCompletedOnboarding = false
    }
}
