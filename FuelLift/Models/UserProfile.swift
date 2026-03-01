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
    var weightGoalKG: Double?
    var goal: String?
    var dietaryPreference: String?
    var workoutsPerWeek: Int?
    var targetWeightKG: Double?

    // Preferences
    var useMetricUnits: Bool
    var darkModeEnabled: Bool
    var notificationsEnabled: Bool
    var healthKitEnabled: Bool
    var appearanceMode: String  // "auto", "light", "dark"

    // Dashboard display preferences
    var showWaterTracker: Bool
    var showWorkoutSummary: Bool
    var showStreakBadge: Bool
    var showQuickActions: Bool
    var showMacrosBreakdown: Bool

    // Notification preferences
    var breakfastReminderEnabled: Bool
    var lunchReminderEnabled: Bool
    var dinnerReminderEnabled: Bool
    var workoutReminderEnabled: Bool
    var breakfastReminderHour: Int
    var breakfastReminderMinute: Int
    var lunchReminderHour: Int
    var lunchReminderMinute: Int
    var dinnerReminderHour: Int
    var dinnerReminderMinute: Int
    var workoutReminderHour: Int
    var workoutReminderMinute: Int

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
        self.appearanceMode = "auto"
        self.notificationsEnabled = true
        self.healthKitEnabled = false
        self.showWaterTracker = true
        self.showWorkoutSummary = true
        self.showStreakBadge = true
        self.showQuickActions = true
        self.showMacrosBreakdown = true
        self.breakfastReminderEnabled = true
        self.lunchReminderEnabled = true
        self.dinnerReminderEnabled = true
        self.workoutReminderEnabled = true
        self.breakfastReminderHour = 8
        self.breakfastReminderMinute = 0
        self.lunchReminderHour = 12
        self.lunchReminderMinute = 0
        self.dinnerReminderHour = 18
        self.dinnerReminderMinute = 0
        self.workoutReminderHour = 17
        self.workoutReminderMinute = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.hasCompletedOnboarding = false
    }
}
