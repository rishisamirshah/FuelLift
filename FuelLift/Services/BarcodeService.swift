import Foundation

final class BarcodeService {
    static let shared = BarcodeService()
    private init() {}

    func lookupBarcode(_ barcode: String) async throws -> NutritionData {
        let urlString = "\(AppConstants.openFoodFactsBaseURL)/\(barcode).json"
        guard let url = URL(string: urlString) else {
            throw BarcodeError.invalidBarcode
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw BarcodeError.productNotFound
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        guard let status = json?["status"] as? Int, status == 1,
              let product = json?["product"] as? [String: Any] else {
            throw BarcodeError.productNotFound
        }

        let name = product["product_name"] as? String ?? "Unknown Product"
        let nutriments = product["nutriments"] as? [String: Any] ?? [:]

        let calories = extractNumber(nutriments, key: "energy-kcal_100g")
        let protein = extractDouble(nutriments, key: "proteins_100g")
        let carbs = extractDouble(nutriments, key: "carbohydrates_100g")
        let fat = extractDouble(nutriments, key: "fat_100g")

        let servingSize = product["serving_size"] as? String ?? "100g"

        // Scale to serving size if available
        let servingGrams = extractServingGrams(from: product)
        let scale = servingGrams / 100.0

        return NutritionData(
            name: name,
            calories: Int(Double(calories) * scale),
            proteinG: protein * scale,
            carbsG: carbs * scale,
            fatG: fat * scale,
            servingSize: servingSize
        )
    }

    private func extractNumber(_ dict: [String: Any], key: String) -> Int {
        if let value = dict[key] as? Int { return value }
        if let value = dict[key] as? Double { return Int(value) }
        if let value = dict[key] as? String, let num = Int(value) { return num }
        return 0
    }

    private func extractDouble(_ dict: [String: Any], key: String) -> Double {
        if let value = dict[key] as? Double { return value }
        if let value = dict[key] as? Int { return Double(value) }
        if let value = dict[key] as? String, let num = Double(value) { return num }
        return 0
    }

    private func extractServingGrams(from product: [String: Any]) -> Double {
        if let qty = product["serving_quantity"] as? Double, qty > 0 {
            return qty
        }
        if let qty = product["serving_quantity"] as? String, let num = Double(qty), num > 0 {
            return num
        }
        return 100.0 // default to per-100g
    }
}

enum BarcodeError: LocalizedError {
    case invalidBarcode
    case productNotFound

    var errorDescription: String? {
        switch self {
        case .invalidBarcode: return "Invalid barcode format."
        case .productNotFound: return "Product not found. Try manual entry."
        }
    }
}
