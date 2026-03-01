import Foundation

final class SpoonacularService {
    static let shared = SpoonacularService()
    private init() {}

    enum SpoonacularError: Error, LocalizedError {
        case noAPIKey
        case invalidResponse
        case apiError(String)
        case quotaExceeded

        var errorDescription: String? {
            switch self {
            case .noAPIKey: return "Spoonacular API key not configured"
            case .invalidResponse: return "Invalid response from Spoonacular"
            case .apiError(let msg): return msg
            case .quotaExceeded: return "Spoonacular daily quota exceeded"
            }
        }
    }

    // MARK: - Search Menu Items

    func searchMenuItems(restaurantName: String) async throws -> [MenuItem] {
        let apiKey = try resolveAPIKey()

        var components = URLComponents(string: "\(AppConstants.spoonacularBaseURL)/food/menuItems/search")!
        components.queryItems = [
            URLQueryItem(name: "query", value: restaurantName),
            URLQueryItem(name: "addMenuItemInformation", value: "true"),
            URLQueryItem(name: "number", value: "20"),
            URLQueryItem(name: "apiKey", value: apiKey)
        ]

        guard let url = components.url else {
            throw SpoonacularError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SpoonacularError.invalidResponse
        }

        if httpResponse.statusCode == 402 {
            throw SpoonacularError.quotaExceeded
        }

        guard httpResponse.statusCode == 200 else {
            throw SpoonacularError.apiError("HTTP \(httpResponse.statusCode)")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let menuItems = json["menuItems"] as? [[String: Any]] else {
            return []
        }

        return menuItems.compactMap { item -> MenuItem? in
            guard let id = item["id"] as? Int,
                  let name = item["title"] as? String else { return nil }

            var calories = 0
            var proteinG = 0.0
            var carbsG = 0.0
            var fatG = 0.0
            var servingSize: String?
            var badges: [String] = []

            if let nutrition = item["nutrition"] as? [String: Any],
               let nutrients = nutrition["nutrients"] as? [[String: Any]] {
                for nutrient in nutrients {
                    guard let nutrientName = nutrient["name"] as? String,
                          let amount = nutrient["amount"] as? Double else { continue }
                    switch nutrientName {
                    case "Calories": calories = Int(amount)
                    case "Protein": proteinG = amount
                    case "Carbohydrates": carbsG = amount
                    case "Fat": fatG = amount
                    default: break
                    }
                }
            }

            if let serving = item["servingSize"] as? String {
                servingSize = serving
            }

            if let badgeList = item["badges"] as? [String] {
                badges = badgeList
            }

            let imageURLString = item["image"] as? String
            let imageURL = imageURLString.flatMap { URL(string: $0) }

            let restaurantChain = item["restaurantChain"] as? String

            return MenuItem(
                id: id,
                name: name,
                restaurantChain: restaurantChain,
                servingSize: servingSize,
                calories: calories,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                imageURL: imageURL,
                badges: badges,
                source: .spoonacular
            )
        }
    }

    // MARK: - Private

    private func resolveAPIKey() throws -> String {
        let key = AppConstants.spoonacularAPIKey
        guard !key.isEmpty, !key.contains("$(") else {
            throw SpoonacularError.noAPIKey
        }
        return key
    }
}
