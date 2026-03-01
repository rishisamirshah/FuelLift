import Foundation
import CoreLocation

struct Restaurant: Identifiable, Hashable {
    let id: String                      // Google Places place_id
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let distanceMeters: Double?
    let isOpen: Bool?
    let photoReference: String?         // Google Places photo name
    let priceLevel: Int?                // 0-4
    let rating: Double?
    let userRatingsTotal: Int?
    let types: [String]

    // CLLocationCoordinate2D is not Hashable, so hash/equate by id only
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        lhs.id == rhs.id
    }

    var distanceText: String? {
        guard let meters = distanceMeters else { return nil }
        if meters < 1000 {
            return "\(Int(meters))m"
        } else {
            let miles = meters / 1609.34
            return String(format: "%.1f mi", miles)
        }
    }

    var priceLevelText: String? {
        guard let level = priceLevel, level > 0 else { return nil }
        return String(repeating: "$", count: level)
    }
}
