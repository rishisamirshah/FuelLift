import Foundation
import CoreLocation

final class FuelFinderService {
    static let shared = FuelFinderService()
    private init() {}

    enum FuelFinderError: Error, LocalizedError {
        case noMenuItems
        case apiError(String)

        var errorDescription: String? {
            switch self {
            case .noMenuItems: return "No menu items found"
            case .apiError(let msg): return msg
            }
        }
    }

    // MARK: - Fetch Nearby Restaurants

    func fetchNearbyRestaurants(coordinate: CLLocationCoordinate2D) async throws -> [Restaurant] {
        try await GooglePlacesService.shared.searchNearbyRestaurants(coordinate: coordinate)
    }

    // MARK: - Search Restaurants by Text

    func searchRestaurants(query: String, coordinate: CLLocationCoordinate2D) async throws -> [Restaurant] {
        try await GooglePlacesService.shared.searchRestaurantsByText(query: query, coordinate: coordinate)
    }

    // MARK: - Fetch Menu Items (Deep Gemini Research)

    func fetchMenuItems(for restaurant: Restaurant, profile: UserProfile?) async throws -> [MenuItem] {
        // Try Spoonacular for image URLs (non-blocking enrichment)
        let spoonacularImages = await fetchSpoonacularImages(restaurantName: restaurant.name)

        // Deep Gemini research - primary source for all menu data
        let items = try await deepGeminiResearch(
            restaurant: restaurant,
            profile: profile
        )

        // Merge Spoonacular images onto Gemini results
        return items.map { item in
            if item.imageURL == nil, let spoonURL = spoonacularImages[item.name.lowercased()] {
                return MenuItem(
                    id: item.id,
                    name: item.name,
                    restaurantChain: item.restaurantChain,
                    servingSize: item.servingSize,
                    calories: item.calories,
                    proteinG: item.proteinG,
                    carbsG: item.carbsG,
                    fatG: item.fatG,
                    imageURL: spoonURL,
                    badges: item.badges,
                    source: item.source,
                    imageSearchQuery: item.imageSearchQuery,
                    healthScore: item.healthScore,
                    description: item.description
                )
            }
            return item
        }
    }

    // MARK: - Score and Sort

    func scoreAndSort(items: [MenuItem], profile: UserProfile) -> [(MenuItem, MenuItemScore)] {
        items.map { item in
            (item, MenuItemScore.calculate(for: item, profile: profile))
        }
        .sorted { $0.1.score > $1.1.score }
    }

    // MARK: - Spoonacular Image Enrichment (non-blocking)

    private func fetchSpoonacularImages(restaurantName: String) async -> [String: URL] {
        do {
            let items = try await SpoonacularService.shared.searchMenuItems(restaurantName: restaurantName)
            var imageMap: [String: URL] = [:]
            for item in items {
                if let url = item.imageURL {
                    imageMap[item.name.lowercased()] = url
                }
            }
            return imageMap
        } catch {
            return [:]
        }
    }

    // MARK: - Deep Gemini Research

    private func deepGeminiResearch(
        restaurant: Restaurant,
        profile: UserProfile?
    ) async throws -> [MenuItem] {
        let apiKey = AppConstants.geminiAPIKey
        guard !apiKey.isEmpty, !apiKey.contains("$(") else {
            throw FuelFinderError.apiError("Gemini API key not configured")
        }

        let dietInfo: String
        let prefsInfo: String
        let allergiesInfo: String
        let goalInfo: String

        if let profile, profile.hasFuelFinderSurvey {
            dietInfo = "User's diet: \(profile.fuelFinderDietType.isEmpty ? "No preference" : profile.fuelFinderDietType)"
            let cuisines = profile.cuisinePreferencesArray
            prefsInfo = cuisines.isEmpty ? "No cuisine preference" : "Preferred cuisines: \(cuisines.joined(separator: ", "))"
            let allergies = profile.allergiesArray
            allergiesInfo = allergies.isEmpty ? "No allergies" : "Allergies/restrictions: \(allergies.joined(separator: ", ")). Flag any items containing these."
            let goal = profile.goal ?? "maintenance"
            let calGoal = profile.calorieGoal
            goalInfo = "Fitness goal: \(goal), daily calorie target: \(calGoal) cal, protein: \(profile.proteinGoal)g, carbs: \(profile.carbsGoal)g, fat: \(profile.fatGoal)g"
        } else {
            dietInfo = "No dietary preferences specified"
            prefsInfo = "No cuisine preference"
            allergiesInfo = "No allergies specified"
            goalInfo = "General healthy eating"
        }

        let prompt = """
        You are an expert nutritionist and food researcher. Research the restaurant "\(restaurant.name)" \
        located at "\(restaurant.address)".

        This is a REAL restaurant. Research their actual menu thoroughly.

        \(dietInfo)
        \(prefsInfo)
        \(allergiesInfo)
        \(goalInfo)

        Return exactly 20 of their best and most popular menu items with accurate nutrition estimates. \
        Prioritize items that match the user's dietary preferences and fitness goals. \
        For each item provide a short descriptive image search query (e.g. "grilled chicken caesar salad restaurant plate") \
        that could be used to find a representative photo of the dish.

        Return a JSON array of objects with these fields:
        - name (string): the dish name
        - description (string): 1-sentence description of the dish
        - calories (integer): estimated calories
        - protein_g (integer): grams of protein
        - carbs_g (integer): grams of carbs
        - fat_g (integer): grams of fat
        - serving_size (string): serving size description
        - badges (array of strings): dietary tags like "vegetarian", "vegan", "gluten-free", "high-protein", "low-carb", "keto-friendly"
        - health_score (integer 0-100): overall healthiness rating
        - image_search_query (string): descriptive search query for finding a photo of this dish

        Be realistic and accurate. Use your knowledge of this restaurant's actual menu when possible.
        """

        let body: [String: Any] = [
            "contents": [["parts": [["text": prompt]]]],
            "generationConfig": [
                "responseMimeType": "application/json",
                "responseSchema": [
                    "type": "ARRAY",
                    "items": [
                        "type": "OBJECT",
                        "properties": [
                            "name": ["type": "STRING"],
                            "description": ["type": "STRING"],
                            "calories": ["type": "INTEGER"],
                            "protein_g": ["type": "INTEGER"],
                            "carbs_g": ["type": "INTEGER"],
                            "fat_g": ["type": "INTEGER"],
                            "serving_size": ["type": "STRING"],
                            "badges": [
                                "type": "ARRAY",
                                "items": ["type": "STRING"]
                            ],
                            "health_score": ["type": "INTEGER"],
                            "image_search_query": ["type": "STRING"]
                        ],
                        "required": ["name", "description", "calories", "protein_g", "carbs_g", "fat_g", "serving_size", "health_score", "image_search_query"]
                    ]
                ]
            ]
        ]

        let urlString = "\(AppConstants.geminiBaseURL)/\(AppConstants.geminiModel):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw FuelFinderError.apiError("Invalid Gemini URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120  // 2 minutes for deep research
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw FuelFinderError.apiError("Gemini request failed")
        }

        // Parse Gemini response
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let responseText = firstPart["text"] as? String else {
            throw FuelFinderError.noMenuItems
        }

        let jsonString = responseText
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonData = jsonString.data(using: .utf8),
              let itemsArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
            throw FuelFinderError.noMenuItems
        }

        return itemsArray.enumerated().compactMap { index, item -> MenuItem? in
            guard let name = item["name"] as? String else { return nil }

            let calories: Int
            if let cal = item["calories"] as? Int {
                calories = cal
            } else if let cal = item["calories"] as? Double {
                calories = Int(cal)
            } else {
                calories = 0
            }

            let proteinG = Double((item["protein_g"] as? Int) ?? Int((item["protein_g"] as? Double) ?? 0))
            let carbsG = Double((item["carbs_g"] as? Int) ?? Int((item["carbs_g"] as? Double) ?? 0))
            let fatG = Double((item["fat_g"] as? Int) ?? Int((item["fat_g"] as? Double) ?? 0))
            let servingSize = item["serving_size"] as? String
            let badges = (item["badges"] as? [String]) ?? []
            let healthScore = (item["health_score"] as? Int) ?? (item["health_score"] as? Double).map(Int.init)
            let imageSearchQuery = item["image_search_query"] as? String
            let description = item["description"] as? String

            // Generate a stable hash-based ID for Gemini items
            let idHash = abs("\(restaurant.name)-\(name)-\(index)".hashValue)

            return MenuItem(
                id: idHash,
                name: name,
                restaurantChain: restaurant.name,
                servingSize: servingSize,
                calories: calories,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                imageURL: nil,
                badges: badges,
                source: .geminiEstimate,
                imageSearchQuery: imageSearchQuery,
                healthScore: healthScore,
                description: description
            )
        }
    }
}
