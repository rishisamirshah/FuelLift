import Foundation

struct NutritionData: Codable, Hashable {
    var name: String
    var calories: Int
    var proteinG: Double
    var carbsG: Double
    var fatG: Double
    var servingSize: String
    var ingredients: [Ingredient]?

    struct Ingredient: Codable, Hashable {
        var name: String
        var calories: Int
    }

    enum CodingKeys: String, CodingKey {
        case name
        case calories
        case proteinG = "protein_g"
        case carbsG = "carbs_g"
        case fatG = "fat_g"
        case servingSize = "serving_size"
        case ingredients
    }
}
