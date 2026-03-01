import Foundation
import CoreLocation

final class GooglePlacesService {
    static let shared = GooglePlacesService()
    private init() {}

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

    // MARK: - Nearby Search (Places API New)

    func searchNearbyRestaurants(
        coordinate: CLLocationCoordinate2D,
        radius: Int = AppConstants.googlePlacesNearbyRadiusMeters
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

        let body: [String: Any] = [
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
        .sorted { ($0.distanceMeters ?? .infinity) < ($1.distanceMeters ?? .infinity) }
    }

    // MARK: - Photo URL

    func photoURL(reference: String, maxWidth: Int = 400) -> URL? {
        let apiKey = AppConstants.googlePlacesAPIKey
        guard !apiKey.isEmpty else { return nil }
        return URL(string: "\(AppConstants.googlePlacesBaseURL)/\(reference)/media?maxWidthPx=\(maxWidth)&key=\(apiKey)")
    }

    // MARK: - Private

    private func resolveAPIKey() throws -> String {
        let key = AppConstants.googlePlacesAPIKey
        guard !key.isEmpty, !key.contains("$(") else {
            throw PlacesError.noAPIKey
        }
        return key
    }
}
