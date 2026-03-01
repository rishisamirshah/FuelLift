import Foundation

enum AppConstants {
    // MARK: - API Keys (loaded from environment / config)
    static var openAIAPIKey: String {
        Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String ?? ""
    }

    // MARK: - OpenAI
    static let openAIBaseURL = "https://api.openai.com/v1/chat/completions"
    static let openAIModel = "gpt-4o"

    // MARK: - Open Food Facts
    static let openFoodFactsBaseURL = "https://world.openfoodfacts.org/api/v2/product"

    // MARK: - Firestore Collections
    enum Collections {
        static let users = "users"
        static let groups = "groups"
        static let workouts = "workouts"
        static let foodEntries = "foodEntries"
        static let friendships = "friendships"
    }

    // MARK: - Defaults
    static let defaultCalorieGoal: Int = 2000
    static let defaultProteinGoal: Int = 150
    static let defaultCarbsGoal: Int = 250
    static let defaultFatGoal: Int = 65
    static let defaultWaterGoalML: Int = 2500

    // MARK: - Anthropic (Claude AI)
    static var anthropicAPIKey: String {
        Bundle.main.infoDictionary?["ANTHROPIC_API_KEY"] as? String ?? ""
    }
    static let anthropicBaseURL = "https://api.anthropic.com/v1/messages"
    static let anthropicModel = "claude-sonnet-4-6"

    // MARK: - Google Gemini
    static var geminiAPIKey: String {
        Bundle.main.infoDictionary?["GEMINI_API_KEY"] as? String ?? ""
    }
    static let geminiBaseURL = "https://generativelanguage.googleapis.com/v1beta/models"
    static let geminiModel = "gemini-2.5-flash"

    // MARK: - Rest Timer Presets (seconds)
    static let restTimerPresets: [Int] = [30, 60, 90, 120, 180, 300]
}
