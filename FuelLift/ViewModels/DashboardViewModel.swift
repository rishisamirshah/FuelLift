import SwiftUI
import SwiftData

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var caloriesEaten: Int = 0
    @Published var calorieGoal: Int = AppConstants.defaultCalorieGoal
    @Published var proteinG: Double = 0
    @Published var carbsG: Double = 0
    @Published var fatG: Double = 0
    @Published var proteinGoal: Int = AppConstants.defaultProteinGoal
    @Published var carbsGoal: Int = AppConstants.defaultCarbsGoal
    @Published var fatGoal: Int = AppConstants.defaultFatGoal
    @Published var waterML: Int = 0
    @Published var waterGoal: Int = AppConstants.defaultWaterGoalML
    @Published var todayWorkout: Workout?
    @Published var currentStreak: Int = 0
    @Published var stepsToday: Int = 0

    var calorieProgress: Double {
        guard calorieGoal > 0 else { return 0 }
        return min(Double(caloriesEaten) / Double(calorieGoal), 1.0)
    }

    var caloriesRemaining: Int {
        max(calorieGoal - caloriesEaten, 0)
    }

    func loadDashboard(context: ModelContext) {
        let today = Date().startOfDay
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        // Load food entries
        let foodDescriptor = FetchDescriptor<FoodEntry>(
            predicate: #Predicate { $0.date >= today && $0.date < tomorrow }
        )
        if let entries = try? context.fetch(foodDescriptor) {
            caloriesEaten = entries.reduce(0) { $0 + $1.calories }
            proteinG = entries.reduce(0) { $0 + $1.proteinG }
            carbsG = entries.reduce(0) { $0 + $1.carbsG }
            fatG = entries.reduce(0) { $0 + $1.fatG }
        }

        // Load water
        let waterDescriptor = FetchDescriptor<WaterEntry>(
            predicate: #Predicate { $0.date >= today && $0.date < tomorrow }
        )
        if let entries = try? context.fetch(waterDescriptor) {
            waterML = entries.reduce(0) { $0 + $1.amountML }
        }

        // Load today's workout
        let workoutDescriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.date >= today && $0.date < tomorrow && $0.isCompleted },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        todayWorkout = try? context.fetch(workoutDescriptor).first

        // Load user profile for goals
        let profileDescriptor = FetchDescriptor<UserProfile>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
        if let profile = try? context.fetch(profileDescriptor).first {
            calorieGoal = profile.calorieGoal
            proteinGoal = profile.proteinGoal
            carbsGoal = profile.carbsGoal
            fatGoal = profile.fatGoal
            waterGoal = profile.waterGoalML
            currentStreak = profile.currentStreak
        }
    }
}
