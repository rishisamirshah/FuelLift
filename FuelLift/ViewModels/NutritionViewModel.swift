import SwiftUI
import SwiftData

@MainActor
final class NutritionViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var todayEntries: [FoodEntry] = []
    @Published var todayWater: [WaterEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    var totalCalories: Int { todayEntries.reduce(0) { $0 + $1.calories } }
    var totalProtein: Double { todayEntries.reduce(0) { $0 + $1.proteinG } }
    var totalCarbs: Double { todayEntries.reduce(0) { $0 + $1.carbsG } }
    var totalFat: Double { todayEntries.reduce(0) { $0 + $1.fatG } }
    var totalWaterML: Int { todayWater.reduce(0) { $0 + $1.amountML } }

    func entriesForMeal(_ mealType: MealType) -> [FoodEntry] {
        todayEntries.filter { $0.mealType == mealType.rawValue }
    }

    func caloriesForMeal(_ mealType: MealType) -> Int {
        entriesForMeal(mealType).reduce(0) { $0 + $1.calories }
    }

    func loadEntries(context: ModelContext) {
        let startOfDay = selectedDate.startOfDay
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let foodDescriptor = FetchDescriptor<FoodEntry>(
            predicate: #Predicate { entry in
                entry.date >= startOfDay && entry.date < endOfDay
            },
            sortBy: [SortDescriptor(\.date)]
        )

        let waterDescriptor = FetchDescriptor<WaterEntry>(
            predicate: #Predicate { entry in
                entry.date >= startOfDay && entry.date < endOfDay
            },
            sortBy: [SortDescriptor(\.date)]
        )

        do {
            todayEntries = try context.fetch(foodDescriptor)
            todayWater = try context.fetch(waterDescriptor)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addFoodEntry(_ entry: FoodEntry, context: ModelContext) {
        context.insert(entry)
        try? context.save()

        // Sync to Firestore
        Task {
            _ = try? await FirestoreService.shared.saveFoodEntry(entry.toFirestoreData())
        }

        loadEntries(context: context)
    }

    func deleteFoodEntry(_ entry: FoodEntry, context: ModelContext) {
        if let firestoreId = entry.firestoreId {
            Task {
                try? await FirestoreService.shared.deleteFoodEntry(id: firestoreId)
            }
        }
        context.delete(entry)
        try? context.save()
        loadEntries(context: context)
    }

    func addWater(amountML: Int, context: ModelContext) {
        let entry = WaterEntry(amountML: amountML)
        context.insert(entry)
        try? context.save()
        loadEntries(context: context)
    }
}
