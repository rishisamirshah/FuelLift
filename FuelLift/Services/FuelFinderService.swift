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

    // MARK: - Fetch Menu Items (Spoonacular first, Gemini fallback)

    func fetchMenuItems(for restaurant: Restaurant) async throws -> [MenuItem] {
        // Try Spoonacular first
        do {
            let items = try await SpoonacularService.shared.searchMenuItems(restaurantName: restaurant.name)
            if !items.isEmpty {
                return items
            }
        } catch {
            print("[FuelFinder] Spoonacular failed for \(restaurant.name): \(error.localizedDescription)")
        }

        // Fallback to Gemini AI estimation
        return try await estimateMenuWithGemini(restaurantName: restaurant.name)
    }

    // MARK: - Score and Sort

    func scoreAndSort(items: [MenuItem], profile: UserProfile) -> [(MenuItem, MenuItemScore)] {
        items.map { item in
            (item, MenuItemScore.calculate(for: item, profile: profile))
        }
        .sorted { $0.1.score > $1.1.score }
    }

    // MARK: - Gemini Fallback

    private func estimateMenuWithGemini(restaurantName: String) async throws -> [MenuItem] {
        let apiKey = AppConstants.geminiAPIKey
        guard !apiKey.isEmpty, !apiKey.contains("$(") else {
            throw FuelFinderError.apiError("Gemini API key not configured")
        }

        let prompt = """
        You are a nutrition expert. For the restaurant "\(restaurantName)", generate 10 typical menu items \
        with estimated nutrition data. Return a JSON array of objects, each with: \
        name (string), calories (integer), protein_g (number), carbs_g (number), fat_g (number), \
        serving_size (string), badges (array of strings like "vegetarian", "vegan", "gluten-free"). \
        Be realistic and accurate with nutrition estimates.
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
                            "calories": ["type": "INTEGER"],
                            "protein_g": ["type": "NUMBER"],
                            "carbs_g": ["type": "NUMBER"],
                            "fat_g": ["type": "NUMBER"],
                            "serving_size": ["type": "STRING"],
                            "badges": [
                                "type": "ARRAY",
                                "items": ["type": "STRING"]
                            ]
                        ],
                        "required": ["name", "calories", "protein_g", "carbs_g", "fat_g", "serving_size"]
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
        request.timeoutInterval = 30
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

            let proteinG = (item["protein_g"] as? Double) ?? (item["protein_g"] as? Int).map(Double.init) ?? 0
            let carbsG = (item["carbs_g"] as? Double) ?? (item["carbs_g"] as? Int).map(Double.init) ?? 0
            let fatG = (item["fat_g"] as? Double) ?? (item["fat_g"] as? Int).map(Double.init) ?? 0
            let servingSize = item["serving_size"] as? String
            let badges = (item["badges"] as? [String]) ?? []

            // Generate a stable hash-based ID for Gemini items
            let idHash = abs("\(restaurantName)-\(name)-\(index)".hashValue)

            return MenuItem(
                id: idHash,
                name: name,
                restaurantChain: restaurantName,
                servingSize: servingSize,
                calories: calories,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                imageURL: nil,
                badges: badges,
                source: .geminiEstimate
            )
        }
    }
}
