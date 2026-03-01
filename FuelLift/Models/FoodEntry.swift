import Foundation
import SwiftData

@Model
final class FoodEntry {
    var id: String
    var name: String
    var calories: Int
    var proteinG: Double
    var carbsG: Double
    var fatG: Double
    var servingSize: String
    var mealType: String  // "breakfast", "lunch", "dinner", "snack"
    var date: Date
    var imageData: Data?
    var barcode: String?
    var source: String  // "ai_scan", "barcode", "manual", "recipe"
    var firestoreId: String?
    var ingredientsJSON: String?
    var analysisStatus: String = "completed"  // "pending", "analyzing", "completed", "failed"
    var aiFeedback: String = "none"           // "none", "thumbs_up", "thumbs_down"

    var ingredients: [NutritionData.Ingredient] {
        guard let data = ingredientsJSON?.data(using: .utf8),
              let items = try? JSONDecoder().decode([NutritionData.Ingredient].self, from: data) else {
            return []
        }
        return items
    }

    init(
        name: String,
        calories: Int,
        proteinG: Double,
        carbsG: Double,
        fatG: Double,
        servingSize: String = "",
        mealType: String = "snack",
        date: Date = Date(),
        source: String = "manual"
    ) {
        self.id = UUID().uuidString
        self.name = name
        self.calories = calories
        self.proteinG = proteinG
        self.carbsG = carbsG
        self.fatG = fatG
        self.servingSize = servingSize
        self.mealType = mealType
        self.date = date
        self.source = source
    }

    var nutrition: NutritionData {
        NutritionData(
            name: name,
            calories: calories,
            proteinG: proteinG,
            carbsG: carbsG,
            fatG: fatG,
            servingSize: servingSize,
            ingredients: ingredients.isEmpty ? nil : ingredients
        )
    }

    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "name": name,
            "calories": calories,
            "proteinG": proteinG,
            "carbsG": carbsG,
            "fatG": fatG,
            "servingSize": servingSize,
            "mealType": mealType,
            "date": date,
            "source": source
        ]
        if let barcode { data["barcode"] = barcode }
        return data
    }
}

enum MealType: String, CaseIterable, Identifiable {
    case breakfast = "breakfast"
    case lunch = "lunch"
    case dinner = "dinner"
    case snack = "snack"

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.fill"
        case .snack: return "leaf.fill"
        }
    }
}
