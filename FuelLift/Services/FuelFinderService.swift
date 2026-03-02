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

    // MARK: - AI Restaurant Ranking

    func aiRankRestaurants(_ restaurants: [Restaurant], profile: UserProfile?) async -> [Restaurant] {
        guard let profile, profile.hasFuelFinderSurvey else { return restaurants }
        guard restaurants.count > 1 else { return restaurants }

        let apiKey = AppConstants.geminiAPIKey
        guard !apiKey.isEmpty, !apiKey.contains("$(") else { return restaurants }

        let dietType = profile.fuelFinderDietType.isEmpty ? "No preference" : profile.fuelFinderDietType
        let goal = profile.goal ?? "maintenance"
        let cuisines = profile.cuisinePreferencesArray
        let allergies = profile.allergiesArray

        // Build restaurant list string
        let restaurantList = restaurants.prefix(40).enumerated().map { i, r in
            "\(i + 1). \(r.name) (Rating: \(r.rating ?? 0), \(r.isOpen == true ? "Open" : "Closed"), \(r.types.prefix(3).joined(separator: ", ")))"
        }.joined(separator: "\n")

        let prompt = """
        You are a fitness nutrition expert. A user needs restaurant recommendations.

        USER PROFILE:
        - Diet: \(dietType)
        - Goal: \(goal)
        - Daily targets: \(profile.calorieGoal) cal, \(profile.proteinGoal)g protein, \(profile.carbsGoal)g carbs, \(profile.fatGoal)g fat
        - Preferred cuisines: \(cuisines.isEmpty ? "Any" : cuisines.joined(separator: ", "))
        - Allergies: \(allergies.isEmpty ? "None" : allergies.joined(separator: ", "))

        NEARBY RESTAURANTS:
        \(restaurantList)

        Rank these restaurants by how well they serve this user's fitness and dietary needs. \
        A restaurant specializing in grilled proteins and salads should rank MUCH higher than a buffet or ice cream shop for someone building muscle. \
        Fast food with few healthy options should rank lower. Restaurants with diverse healthy menus rank higher.

        Return a JSON array of objects with:
        - index (integer): the original restaurant number (1-based)
        - fitness_score (integer 0-100): how well this restaurant serves the user's fitness goals

        Return ALL restaurants, sorted by fitness_score descending. Be harsh — a burger joint should score 30-50 for weight loss, not 70+.
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
                            "index": ["type": "INTEGER"],
                            "fitness_score": ["type": "INTEGER"]
                        ],
                        "required": ["index", "fitness_score"]
                    ]
                ]
            ]
        ]

        let urlString = "\(AppConstants.geminiBaseURL)/\(AppConstants.geminiModel):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else { return restaurants }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return restaurants
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let responseText = firstPart["text"] as? String else {
            return restaurants
        }

        let jsonString = responseText
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonData = jsonString.data(using: .utf8),
              let rankings = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
            return restaurants
        }

        // Build index-to-score map
        let capped = Array(restaurants.prefix(40))
        var scoreMap: [Int: Int] = [:]
        for ranking in rankings {
            if let index = ranking["index"] as? Int,
               let fitnessScore = ranking["fitness_score"] as? Int {
                scoreMap[index - 1] = fitnessScore  // Convert to 0-based
            }
        }

        // Sort restaurants by AI fitness score
        var indexed = capped.enumerated().map { ($0.offset, $0.element) }
        indexed.sort { a, b in
            let aScore = scoreMap[a.0] ?? 50
            let bScore = scoreMap[b.0] ?? 50
            return aScore > bScore
        }

        return indexed.map { $0.1 }
    }

    // MARK: - Fetch Menu Items (Deep Gemini Research with AI Scoring)

    func fetchMenuItems(for restaurant: Restaurant, profile: UserProfile?) async throws -> [MenuItem] {
        // Try Spoonacular for image URLs (non-blocking enrichment)
        async let spoonacularImagesTask = fetchSpoonacularImages(restaurantName: restaurant.name)

        // Deep Gemini research with personalized AI scoring
        let items = try await deepGeminiResearch(
            restaurant: restaurant,
            profile: profile
        )

        let spoonacularImages = await spoonacularImagesTask

        // Merge Spoonacular images onto Gemini results
        var enrichedItems = items.map { item -> MenuItem in
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
                    description: item.description,
                    userMatchScore: item.userMatchScore,
                    userMatchRationale: item.userMatchRationale
                )
            }
            return item
        }

        // Fetch food images via Google Custom Search for items still missing images
        enrichedItems = await enrichWithGoogleImages(items: enrichedItems)

        return enrichedItems
    }

    // MARK: - Score and Sort

    func scoreAndSort(items: [MenuItem], profile: UserProfile) -> [(MenuItem, MenuItemScore)] {
        items.map { item in
            (item, MenuItemScore.calculate(for: item, profile: profile))
        }
        .sorted { $0.1.score > $1.1.score }
    }

    // MARK: - Google Custom Search Image Enrichment

    private func enrichWithGoogleImages(items: [MenuItem]) async -> [MenuItem] {
        // Collect items that need images and have a search query
        let needsImage = items.enumerated().filter { $0.element.imageURL == nil && $0.element.imageSearchQuery != nil }

        guard !needsImage.isEmpty else { return items }

        // Batch search for images (limited to top 10 items to save quota)
        let queries = needsImage.prefix(10).compactMap { $0.element.imageSearchQuery }
        let imageResults = await ImageSearchService.shared.batchSearchFoodImages(queries: queries)

        guard !imageResults.isEmpty else { return items }

        // Merge image URLs back onto items
        return items.map { item in
            if item.imageURL == nil,
               let query = item.imageSearchQuery,
               let imageURL = imageResults[query] {
                return MenuItem(
                    id: item.id,
                    name: item.name,
                    restaurantChain: item.restaurantChain,
                    servingSize: item.servingSize,
                    calories: item.calories,
                    proteinG: item.proteinG,
                    carbsG: item.carbsG,
                    fatG: item.fatG,
                    imageURL: imageURL,
                    badges: item.badges,
                    source: item.source,
                    imageSearchQuery: item.imageSearchQuery,
                    healthScore: item.healthScore,
                    description: item.description,
                    userMatchScore: item.userMatchScore,
                    userMatchRationale: item.userMatchRationale
                )
            }
            return item
        }
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

    // MARK: - Deep Gemini Research with Personalized AI Scoring

    private func deepGeminiResearch(
        restaurant: Restaurant,
        profile: UserProfile?
    ) async throws -> [MenuItem] {
        let apiKey = AppConstants.geminiAPIKey
        guard !apiKey.isEmpty, !apiKey.contains("$(") else {
            throw FuelFinderError.apiError("Gemini API key not configured")
        }

        let userContext: String
        if let profile, profile.hasFuelFinderSurvey {
            let dietType = profile.fuelFinderDietType.isEmpty ? "No preference" : profile.fuelFinderDietType
            let cuisines = profile.cuisinePreferencesArray
            let proteins = profile.proteinPreferencesArray
            let allergies = profile.allergiesArray
            let goal = profile.goal ?? "maintenance"

            userContext = """
            USER PROFILE (use this to personalize recommendations):
            - Diet type: \(dietType)
            - Fitness goal: \(goal)
            - Daily targets: \(profile.calorieGoal) cal, \(profile.proteinGoal)g protein, \(profile.carbsGoal)g carbs, \(profile.fatGoal)g fat
            - Preferred cuisines: \(cuisines.isEmpty ? "Any" : cuisines.joined(separator: ", "))
            - Preferred proteins: \(proteins.isEmpty ? "Any" : proteins.joined(separator: ", "))
            - Allergies/restrictions: \(allergies.isEmpty ? "None" : allergies.joined(separator: ", "))

            SCORING RULES for user_match_score:
            - Score 90-100: Perfect match — hits protein/calorie targets, matches diet type, uses preferred proteins, no allergens
            - Score 70-89: Good match — close to targets, healthy option even if not perfectly aligned
            - Score 50-69: Okay — edible but doesn't strongly support their goals
            - Score 30-49: Poor — too many calories, too little protein, or contains allergens
            - Score 0-29: Terrible — desserts, sugary drinks, deep fried junk for someone trying to lose weight/gain muscle

            CRITICAL: For someone building muscle or losing fat, ice cream, shakes, fries, and desserts should score 0-25. \
            Grilled chicken, fish, salads with protein, lean meats should score 80-100. \
            Be a STRICT fitness nutritionist. Do NOT recommend junk food as healthy.
            """
        } else {
            userContext = """
            No user profile available. Score items by general healthiness:
            - Score 90-100: Very healthy (lean protein, vegetables, whole grains)
            - Score 70-89: Healthy (balanced macros, not too caloric)
            - Score 50-69: Average (typical restaurant food)
            - Score 30-49: Unhealthy (high calorie, high fat, processed)
            - Score 0-29: Very unhealthy (desserts, fried food, sugary drinks)
            """
        }

        let prompt = """
        You are an expert fitness nutritionist researching "\(restaurant.name)" at "\(restaurant.address)".

        This is a REAL restaurant. Research their actual menu thoroughly.

        \(userContext)

        Return exactly 20 menu items. Include their REAL menu items — popular dishes, signature items, healthy options. \
        Do NOT make up fake items. For each item, provide:
        1. Accurate nutrition estimates based on typical restaurant portions
        2. A personalized user_match_score (0-100) based on the scoring rules above
        3. A brief rationale explaining WHY this score — reference the user's specific goals

        Sort the items by user_match_score descending (best matches first).

        Return a JSON array with these fields:
        - name (string): the actual dish name from their menu
        - description (string): 1-sentence description
        - calories (integer): estimated calories
        - protein_g (integer): grams of protein
        - carbs_g (integer): grams of carbs
        - fat_g (integer): grams of fat
        - serving_size (string): serving size
        - badges (array of strings): tags like "high-protein", "low-carb", "vegetarian", "vegan", "gluten-free", "keto-friendly"
        - health_score (integer 0-100): objective healthiness regardless of user
        - user_match_score (integer 0-100): how well this matches THIS specific user's goals
        - user_match_rationale (string): 1 sentence explaining the score for this user
        - image_search_query (string): descriptive query to find a photo of this dish
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
                            "user_match_score": ["type": "INTEGER"],
                            "user_match_rationale": ["type": "STRING"],
                            "image_search_query": ["type": "STRING"]
                        ],
                        "required": ["name", "description", "calories", "protein_g", "carbs_g", "fat_g", "serving_size", "health_score", "user_match_score", "user_match_rationale", "image_search_query"]
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
            let userMatchScore = (item["user_match_score"] as? Int) ?? (item["user_match_score"] as? Double).map(Int.init)
            let userMatchRationale = item["user_match_rationale"] as? String
            let imageSearchQuery = item["image_search_query"] as? String
            let description = item["description"] as? String

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
                description: description,
                userMatchScore: userMatchScore,
                userMatchRationale: userMatchRationale
            )
        }
    }
}
