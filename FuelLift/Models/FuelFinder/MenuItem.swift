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
    let imageURL: URL?                  // Spoonacular CDN image or search-based URL
    let badges: [String]                // "vegetarian", "vegan", etc.
    let source: MenuItemSource
    let imageSearchQuery: String?       // For image lookup
    let healthScore: Int?               // 0-100 health rating from Gemini
    let description: String?            // Item description
    let userMatchScore: Int?            // 0-100 AI personalized score for this user
    let userMatchRationale: String?     // AI explanation of why this item matches/doesn't

    enum MenuItemSource: String, Hashable {
        case spoonacular
        case geminiEstimate
    }

    var macroSummary: String {
        "\(Int(proteinG))P  \(Int(carbsG))C  \(Int(fatG))F"
    }
}
