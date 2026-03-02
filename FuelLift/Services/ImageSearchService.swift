import Foundation

final class ImageSearchService {
    static let shared = ImageSearchService()
    private init() {}

    private var cache: [String: URL] = [:]

    // MARK: - Search for Food Image

    /// Fetches a food image URL using Google Custom Search JSON API.
    /// Returns nil if no API key/CSE ID configured or no results found.
    func searchFoodImage(query: String) async -> URL? {
        let cacheKey = query.lowercased()
        if let cached = cache[cacheKey] { return cached }

        let apiKey = AppConstants.googlePlacesAPIKey  // Same GCP project key
        let cseID = AppConstants.googleCSEID

        guard !apiKey.isEmpty, !apiKey.contains("$("),
              !cseID.isEmpty, !cseID.contains("$(") else {
            return nil
        }

        var components = URLComponents(string: AppConstants.googleCSEBaseURL)!
        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "cx", value: cseID),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "searchType", value: "image"),
            URLQueryItem(name: "num", value: "1"),
            URLQueryItem(name: "imgSize", value: "medium"),
            URLQueryItem(name: "safe", value: "active")
        ]

        guard let url = components.url else { return nil }

        var request = URLRequest(url: url)
        request.timeoutInterval = 10

        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return nil
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let items = json["items"] as? [[String: Any]],
              let firstItem = items.first,
              let link = firstItem["link"] as? String,
              let imageURL = URL(string: link) else {
            return nil
        }

        cache[cacheKey] = imageURL
        return imageURL
    }

    // MARK: - Batch Search (parallel, rate-limited)

    /// Fetches food images for multiple queries in parallel.
    /// Returns a map of query → image URL.
    func batchSearchFoodImages(queries: [String]) async -> [String: URL] {
        // Limit to 10 concurrent image searches to stay under rate limits
        let limitedQueries = Array(queries.prefix(10))

        return await withTaskGroup(of: (String, URL?).self) { group in
            for query in limitedQueries {
                group.addTask {
                    let url = await self.searchFoodImage(query: query)
                    return (query, url)
                }
            }

            var results: [String: URL] = [:]
            for await (query, url) in group {
                if let url {
                    results[query] = url
                }
            }
            return results
        }
    }
}
