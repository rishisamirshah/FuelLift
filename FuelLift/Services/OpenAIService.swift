import Foundation
import UIKit

final class OpenAIService {
    static let shared = OpenAIService()
    private init() {}

    func analyzeFoodPhoto(_ image: UIImage) async throws -> NutritionData {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw OpenAIError.invalidImage
        }

        let base64 = imageData.base64EncodedString()
        let apiKey = AppConstants.openAIAPIKey

        guard !apiKey.isEmpty else {
            throw OpenAIError.missingAPIKey
        }

        let requestBody: [String: Any] = [
            "model": AppConstants.openAIModel,
            "messages": [
                [
                    "role": "system",
                    "content": "You are a nutrition analysis AI. Analyze food photos and return ONLY valid JSON with nutritional estimates. Be as accurate as possible with portion sizes visible in the image."
                ],
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": """
                            Analyze this food photo. Estimate the nutritional content based on what you see.
                            Return ONLY a valid JSON object with this exact format, no other text:
                            {"name":"food name","calories":000,"protein_g":00.0,"carbs_g":00.0,"fat_g":00.0,"serving_size":"estimated portion"}
                            """
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64)",
                                "detail": "high"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 300,
            "temperature": 0.1
        ]

        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)

        var request = URLRequest(url: URL(string: AppConstants.openAIBaseURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.networkError
        }

        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OpenAIError.apiError(statusCode: httpResponse.statusCode, message: errorBody)
        }

        // Parse the response
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let choices = json?["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw OpenAIError.parseError
        }

        // Extract JSON from the response content (handle markdown code blocks)
        let cleanedContent = content
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let nutritionData = cleanedContent.data(using: .utf8) else {
            throw OpenAIError.parseError
        }

        let nutrition = try JSONDecoder().decode(NutritionData.self, from: nutritionData)
        return nutrition
    }
}

enum OpenAIError: LocalizedError {
    case invalidImage
    case missingAPIKey
    case networkError
    case apiError(statusCode: Int, message: String)
    case parseError

    var errorDescription: String? {
        switch self {
        case .invalidImage: return "Could not process the image."
        case .missingAPIKey: return "OpenAI API key is not configured."
        case .networkError: return "Network request failed."
        case .apiError(let code, let msg): return "API error (\(code)): \(msg)"
        case .parseError: return "Could not parse the AI response."
        }
    }
}
