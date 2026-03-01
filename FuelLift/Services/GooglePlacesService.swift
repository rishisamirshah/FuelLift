import Foundation
import CoreLocation

final class GooglePlacesService {
    static let shared = GooglePlacesService()
    private init() {}

    // Non-restaurant types to filter out
    private let excludedTypes: Set<String> = [
        "movie_theater", "bowling_alley", "amusement_park", "casino",
        "night_club", "bar", "gas_station", "convenience_store",
        "grocery_store", "supermarket", "lodging", "hotel"
    ]

    enum PlacesError: Error, LocalizedError {
        case noAPIKey
        case invalidResponse
        case apiError(String)
        case noResults

        var errorDescription: String? {
            switch self {
            case .noAPIKey: return "Google Places API key not configured"
            case .invalidResponse: return "Invalid response from Google Places"
            case .apiError(let msg): return msg
            case .noResults: return "No restaurants found nearby"
            }
        }
    }

    // MARK: - Merged Nearby Search (DISTANCE + POPULARITY)

    func searchNearbyRestaurants(
        coordinate: CLLocationCoordinate2D,
        radius: Int = AppConstants.googlePlacesNearbyRadiusMeters
    ) async throws -> [Restaurant] {
        // Run two searches in parallel: by distance and by popularity
        async let distanceResults = searchNearby(
            coordinate: coordinate,
            radius: radius,
            rankPreference: "DISTANCE"
        )
        async let popularityResults = searchNearby(
            coordinate: coordinate,
            radius: radius,
            rankPreference: "POPULARITY"
        )

        let byDistance = (try? await distanceResults) ?? []
        let byPopularity = (try? await popularityResults) ?? []

        // Merge and deduplicate by id
        var seen = Set<String>()
        var merged: [Restaurant] = []

        for restaurant in byDistance + byPopularity {
            if !seen.contains(restaurant.id) {
                seen.insert(restaurant.id)
                merged.append(restaurant)
            }
        }

        // Filter out non-restaurants
        merged = merged.filter { restaurant in
            !restaurant.types.contains(where: { excludedTypes.contains($0) })
        }

        // Sort by quality: rating * ln(reviewCount + 1), open restaurants first
        merged.sort { a, b in
            let aScore = qualityScore(for: a)
            let bScore = qualityScore(for: b)
            return aScore > bScore
        }

        if merged.isEmpty {
            throw PlacesError.noResults
        }

        return merged
    }

    // MARK: - Text Search (for real search functionality)

    func searchRestaurantsByText(
        query: String,
        coordinate: CLLocationCoordinate2D,
        radius: Int = AppConstants.googlePlacesNearbyRadiusMeters
    ) async throws -> [Restaurant] {
        let apiKey = try resolveAPIKey()

        let url = URL(string: "\(AppConstants.googlePlacesBaseURL)/places:searchText")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue(
            "places.id,places.displayName,places.formattedAddress,places.location,places.currentOpeningHours,places.photos,places.rating,places.userRatingCount,places.priceLevel,places.types",
            forHTTPHeaderField: "X-Goog-FieldMask"
        )
        request.timeoutInterval = 15

        let body: [String: Any] = [
            "textQuery": "\(query) restaurant",
            "locationBias": [
                "circle": [
                    "center": [
                        "latitude": coordinate.latitude,
                        "longitude": coordinate.longitude
                    ],
                    "radius": Double(radius)
                ]
            ],
            "includedType": "restaurant",
            "maxResultCount": 20
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw PlacesError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if let errorJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJSON["error"] as? [String: Any],
               let msg = error["message"] as? String {
                throw PlacesError.apiError(msg)
            }
            throw PlacesError.apiError("HTTP \(httpResponse.statusCode)")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let places = json["places"] as? [[String: Any]] else {
            return []
        }

        let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        var results = places.compactMap { place -> Restaurant? in
            parsePlace(place, userLocation: userLocation)
        }

        // Filter out non-restaurants
        results = results.filter { restaurant in
            !restaurant.types.contains(where: { excludedTypes.contains($0) })
        }

        return results
    }

    // MARK: - Photo URL

    func photoURL(reference: String, maxWidth: Int = 400) -> URL? {
        let apiKey = AppConstants.googlePlacesAPIKey
        guard !apiKey.isEmpty else { return nil }
        return URL(string: "\(AppConstants.googlePlacesBaseURL)/\(reference)/media?maxWidthPx=\(maxWidth)&key=\(apiKey)")
    }

    // MARK: - Private

    private func searchNearby(
        coordinate: CLLocationCoordinate2D,
        radius: Int,
        rankPreference: String
    ) async throws -> [Restaurant] {
        let apiKey = try resolveAPIKey()

        let url = URL(string: "\(AppConstants.googlePlacesBaseURL)/places:searchNearby")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue(
            "places.id,places.displayName,places.formattedAddress,places.location,places.currentOpeningHours,places.photos,places.rating,places.userRatingCount,places.priceLevel,places.types",
            forHTTPHeaderField: "X-Goog-FieldMask"
        )
        request.timeoutInterval = 15

        var body: [String: Any] = [
            "includedTypes": ["restaurant"],
            "maxResultCount": 20,
            "locationRestriction": [
                "circle": [
                    "center": [
                        "latitude": coordinate.latitude,
                        "longitude": coordinate.longitude
                    ],
                    "radius": Double(radius)
                ]
            ]
        ]

        if rankPreference != "DISTANCE" {
            body["rankPreference"] = rankPreference
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw PlacesError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if let errorJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJSON["error"] as? [String: Any],
               let msg = error["message"] as? String {
                throw PlacesError.apiError(msg)
            }
            throw PlacesError.apiError("HTTP \(httpResponse.statusCode)")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let places = json["places"] as? [[String: Any]] else {
            return []
        }

        let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        return places.compactMap { place -> Restaurant? in
            parsePlace(place, userLocation: userLocation)
        }
    }

    private func parsePlace(_ place: [String: Any], userLocation: CLLocation) -> Restaurant? {
        guard let placeId = place["id"] as? String,
              let displayName = place["displayName"] as? [String: Any],
              let name = displayName["text"] as? String,
              let location = place["location"] as? [String: Any],
              let lat = location["latitude"] as? Double,
              let lng = location["longitude"] as? Double else {
            return nil
        }

        let placeLocation = CLLocation(latitude: lat, longitude: lng)
        let distance = userLocation.distance(from: placeLocation)

        let openingHours = place["currentOpeningHours"] as? [String: Any]
        let isOpen = openingHours?["openNow"] as? Bool

        var photoRef: String?
        if let photos = place["photos"] as? [[String: Any]],
           let firstPhoto = photos.first,
           let photoName = firstPhoto["name"] as? String {
            photoRef = photoName
        }

        let priceLevelRaw = place["priceLevel"] as? String
        let priceLevel: Int? = {
            switch priceLevelRaw {
            case "PRICE_LEVEL_FREE": return 0
            case "PRICE_LEVEL_INEXPENSIVE": return 1
            case "PRICE_LEVEL_MODERATE": return 2
            case "PRICE_LEVEL_EXPENSIVE": return 3
            case "PRICE_LEVEL_VERY_EXPENSIVE": return 4
            default: return nil
            }
        }()

        return Restaurant(
            id: placeId,
            name: name,
            address: (place["formattedAddress"] as? String) ?? "",
            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng),
            distanceMeters: distance,
            isOpen: isOpen,
            photoReference: photoRef,
            priceLevel: priceLevel,
            rating: place["rating"] as? Double,
            userRatingsTotal: place["userRatingCount"] as? Int,
            types: (place["types"] as? [String]) ?? []
        )
    }

    private func qualityScore(for restaurant: Restaurant) -> Double {
        let rating = restaurant.rating ?? 0
        let reviews = Double(restaurant.userRatingsTotal ?? 0)
        let openBonus: Double = (restaurant.isOpen == true) ? 1.2 : 1.0
        return rating * log(reviews + 1) * openBonus
    }

    private func resolveAPIKey() throws -> String {
        let key = AppConstants.googlePlacesAPIKey
        guard !key.isEmpty, !key.contains("$(") else {
            throw PlacesError.noAPIKey
        }
        return key
    }
}
