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

    // MARK: - Analyze Food Photo

    func analyzeFoodPhoto(_ image: UIImage) async throws -> NutritionData {
        let apiKey = AppConstants.geminiAPIKey
        guard !apiKey.isEmpty else { throw GeminiError.noAPIKey }

        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw GeminiError.invalidResponse
        }
        let base64String = imageData.base64EncodedString()

        let urlString = "\(AppConstants.geminiBaseURL)/\(AppConstants.geminiModel):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw GeminiError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

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
                            "text": "Identify this food and estimate its nutrition. Break down each visible ingredient with its estimated calories. Respond ONLY with valid JSON, no other text or markdown: {\"name\":\"...\",\"calories\":0,\"protein_g\":0.0,\"carbs_g\":0.0,\"fat_g\":0.0,\"serving_size\":\"...\",\"ingredients\":[{\"name\":\"...\",\"calories\":0}]}"
                        ]
                    ]
                ]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        return try await sendRequest(request)
    }

    // MARK: - Analyze Food Description

    func analyzeFoodDescription(_ text: String) async throws -> NutritionData {
        let apiKey = AppConstants.geminiAPIKey
        guard !apiKey.isEmpty else { throw GeminiError.noAPIKey }

        let urlString = "\(AppConstants.geminiBaseURL)/\(AppConstants.geminiModel):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw GeminiError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        [
                            "text": "You are a nutrition expert. Given this food description, estimate the nutrition and break down each ingredient with its estimated calories. Respond ONLY with valid JSON, no other text or markdown: {\"name\":\"...\",\"calories\":0,\"protein_g\":0.0,\"carbs_g\":0.0,\"fat_g\":0.0,\"serving_size\":\"...\",\"ingredients\":[{\"name\":\"...\",\"calories\":0}]}\n\nFood: \(text)"
                        ]
                    ]
                ]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        return try await sendRequest(request)
    }

    // MARK: - Private

    private func sendRequest(_ request: URLRequest) async throws -> NutritionData {
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
            throw GeminiError.invalidResponse
        }

        // Strip markdown code blocks if present
        let jsonString = responseText
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw GeminiError.invalidResponse
        }

        return try JSONDecoder().decode(NutritionData.self, from: jsonData)
    }
}
