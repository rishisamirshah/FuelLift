import SwiftUI
import SwiftData

@MainActor
final class ProgressViewModel: ObservableObject {
    @Published var weightHistory: [(date: Date, weight: Double)] = []
    @Published var calorieHistory: [(date: Date, calories: Int)] = []
    @Published var exercisePRs: [String: Double] = [:]  // exerciseName -> best e1RM

    func loadData(context: ModelContext) {
        loadWeightHistory(context: context)
        loadCalorieHistory(context: context)
        loadPRs(context: context)
    }

    private func loadWeightHistory(context: ModelContext) {
        let descriptor = FetchDescriptor<BodyMetric>(
            sortBy: [SortDescriptor(\.date)]
        )
        guard let metrics = try? context.fetch(descriptor) else { return }
        weightHistory = metrics.compactMap { metric in
            guard let w = metric.weightKG else { return nil }
            return (metric.date, w)
        }
    }

    private func loadCalorieHistory(context: ModelContext) {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let descriptor = FetchDescriptor<FoodEntry>(
            predicate: #Predicate { $0.date >= thirtyDaysAgo },
            sortBy: [SortDescriptor(\.date)]
        )
        guard let entries = try? context.fetch(descriptor) else { return }

        // Group by day
        var dailyCalories: [Date: Int] = [:]
        for entry in entries {
            let day = entry.date.startOfDay
            dailyCalories[day, default: 0] += entry.calories
        }
        calorieHistory = dailyCalories.sorted(by: { $0.key < $1.key }).map { ($0.key, $0.value) }
    }

    private func loadPRs(context: ModelContext) {
        let descriptor = FetchDescriptor<ExerciseSet>(
            predicate: #Predicate { $0.isCompleted && !$0.isWarmup }
        )
        guard let sets = try? context.fetch(descriptor) else { return }

        var prs: [String: Double] = [:]
        for set in sets {
            let e1rm = set.estimated1RM
            if e1rm > (prs[set.exerciseName] ?? 0) {
                prs[set.exerciseName] = e1rm
            }
        }
        exercisePRs = prs
    }
}
