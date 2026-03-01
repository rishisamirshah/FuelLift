import Foundation

struct MenuItem: Identifiable, Hashable {
    let id: Int                         // Spoonacular ID or hash for Gemini items
    let name: String
    let restaurantChain: String?
    let servingSize: String?
    let calories: Int
    let proteinG: Double
    let carbsG: Double
    let fatG: Double
    let imageURL: URL?                  // Spoonacular CDN image
    let badges: [String]                // "vegetarian", "vegan", etc.
    let source: MenuItemSource

    enum MenuItemSource: String, Hashable {
        case spoonacular
        case geminiEstimate
    }

    var macroSummary: String {
        "\(proteinG.oneDecimal)P  \(carbsG.oneDecimal)C  \(fatG.oneDecimal)F"
    }
}
