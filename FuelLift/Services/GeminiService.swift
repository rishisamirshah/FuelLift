import Foundation
import UIKit

final class GeminiService {
    static let shared = GeminiService()
    private init() {}

    enum GeminiError: Error, LocalizedError {
        case invalidResponse
        case apiError(String)
        case noAPIKey

        var errorDescription: String? {
            switch self {
            case .invalidResponse: return "Invalid response from Gemini"
            case .apiError(let msg): return msg
            case .noAPIKey: return "Gemini API key not configured"
            }
        }
    }

    private let nutritionPrompt = """
    Identify this food and estimate its nutritional content per serving. \
    Break down each visible ingredient with its estimated calories. \
    Return JSON with these exact fields: \
    name (string), calories (integer), protein_g (number), carbs_g (number), \
    fat_g (number), serving_size (string), ingredients (array of objects with name and calories).
    """

    // MARK: - Analyze Food Photo

    func analyzeFoodPhoto(_ image: UIImage) async throws -> NutritionData {
        let apiKey = try resolveAPIKey()

        guard let imageData = image.jpegData(compressionQuality: 0.6) else {
            throw GeminiError.invalidResponse
        }
        let base64String = imageData.base64EncodedString()

        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        [
                            "inlineData": [
                                "mimeType": "image/jpeg",
                                "data": base64String
                            ]
                        ],
                        [
                            "text": nutritionPrompt
                        ]
                    ]
                ]
            ],
            "generationConfig": generationConfig
        ]

        return try await makeRequest(apiKey: apiKey, body: body)
    }

    // MARK: - Analyze Food Description

    func analyzeFoodDescription(_ text: String) async throws -> NutritionData {
        let apiKey = try resolveAPIKey()

        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        [
                            "text": "\(nutritionPrompt)\n\nFood: \(text)"
                        ]
                    ]
                ]
            ],
            "generationConfig": generationConfig
        ]

        return try await makeRequest(apiKey: apiKey, body: body)
    }

    // MARK: - Private

    private var generationConfig: [String: Any] {
        [
            "responseMimeType": "application/json",
            "responseSchema": [
                "type": "OBJECT",
                "properties": [
                    "name": ["type": "STRING"],
                    "calories": ["type": "INTEGER"],
                    "protein_g": ["type": "NUMBER"],
                    "carbs_g": ["type": "NUMBER"],
                    "fat_g": ["type": "NUMBER"],
                    "serving_size": ["type": "STRING"],
                    "ingredients": [
                        "type": "ARRAY",
                        "items": [
                            "type": "OBJECT",
                            "properties": [
                                "name": ["type": "STRING"],
                                "calories": ["type": "INTEGER"]
                            ]
                        ]
                    ]
                ],
                "required": ["name", "calories", "protein_g", "carbs_g", "fat_g", "serving_size"]
            ]
        ]
    }

    private func resolveAPIKey() throws -> String {
        let apiKey = AppConstants.geminiAPIKey
        guard !apiKey.isEmpty, !apiKey.contains("$(") else {
            throw GeminiError.noAPIKey
        }
        return apiKey
    }

    private func makeRequest(apiKey: String, body: [String: Any]) async throws -> NutritionData {
        let urlString = "\(AppConstants.geminiBaseURL)/\(AppConstants.geminiModel):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw GeminiError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if let errorJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJSON["error"] as? [String: Any],
               let errorMsg = error["message"] as? String {
                throw GeminiError.apiError(errorMsg)
            }
            throw GeminiError.apiError("HTTP \(httpResponse.statusCode)")
        }

        // Parse Gemini response: { candidates: [{ content: { parts: [{ text: "..." }] } }] }
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let responseText = firstPart["text"] as? String else {
            // Check for safety block
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let feedback = json["promptFeedback"] as? [String: Any],
               let reason = feedback["blockReason"] as? String {
                throw GeminiError.apiError("Blocked by safety filter: \(reason)")
            }
            throw GeminiError.invalidResponse
        }

        // Clean up response text (strip markdown if present despite JSON mode)
        let jsonString = responseText
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw GeminiError.invalidResponse
        }

        // Decode with lenient number handling
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(NutritionData.self, from: jsonData)
        } catch {
            // If standard decoding fails, try fixing number types manually
            if var parsed = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                // Ensure calories is Int
                if let cal = parsed["calories"] as? Double {
                    parsed["calories"] = Int(cal)
                }
                // Ensure ingredient calories are Int
                if var ingredients = parsed["ingredients"] as? [[String: Any]] {
                    for i in ingredients.indices {
                        if let cal = ingredients[i]["calories"] as? Double {
                            ingredients[i]["calories"] = Int(cal)
                        }
                    }
                    parsed["ingredients"] = ingredients
                }
                let fixedData = try JSONSerialization.data(withJSONObject: parsed)
                return try decoder.decode(NutritionData.self, from: fixedData)
            }
            throw GeminiError.apiError("Failed to parse nutrition data: \(error.localizedDescription)")
        }
    }
}
