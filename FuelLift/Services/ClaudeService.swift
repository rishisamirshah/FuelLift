import Foundation

final class ClaudeService {
    static let shared = ClaudeService()
    private init() {}

    struct GeneratedWorkoutPlan: Codable {
        let routines: [GeneratedRoutine]
    }

    struct GeneratedRoutine: Codable {
        let name: String
        let exercises: [String]
        let setsPerExercise: Int
        let notes: String
    }

    struct ConversationMessage: Codable {
        let role: String
        let content: String
    }

    struct NutritionGoals: Codable {
        let calories: Int
        let proteinG: Int
        let carbsG: Int
        let fatG: Int
        let reasoning: String
    }

    enum ClaudeError: Error, LocalizedError {
        case invalidResponse
        case apiError(String)
        case noAPIKey

        var errorDescription: String? {
            switch self {
            case .invalidResponse: return "Invalid response from AI"
            case .apiError(let msg): return msg
            case .noAPIKey: return "API key not configured"
            }
        }
    }

    func generateWorkoutPlan(
        goal: String,
        experience: String,
        daysPerWeek: Int,
        sessionLength: String,
        equipment: [String],
        userStats: (height: Double?, weight: Double?, age: Int?)
    ) async throws -> GeneratedWorkoutPlan {
        let apiKey = AppConstants.anthropicAPIKey
        guard !apiKey.isEmpty else { throw ClaudeError.noAPIKey }

        guard let url = URL(string: AppConstants.anthropicBaseURL) else {
            throw ClaudeError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let statsInfo: String = {
            var parts: [String] = []
            if let h = userStats.height { parts.append("Height: \(Int(h))cm") }
            if let w = userStats.weight { parts.append("Weight: \(Int(w))kg") }
            if let a = userStats.age { parts.append("Age: \(a)") }
            return parts.isEmpty ? "Not provided" : parts.joined(separator: ", ")
        }()

        let userPrompt = """
        Create a workout plan with these parameters:
        - Goal: \(goal)
        - Experience: \(experience)
        - Days per week: \(daysPerWeek)
        - Session length: \(sessionLength)
        - Available equipment: \(equipment.joined(separator: ", "))
        - User stats: \(statsInfo)
        """

        let body: [String: Any] = [
            "model": AppConstants.anthropicModel,
            "max_tokens": 2048,
            "system": """
            You are a certified personal trainer creating workout plans. Respond ONLY with valid JSON in this exact format, no other text:
            {
              "routines": [
                {
                  "name": "Day Name (e.g. Push Day)",
                  "exercises": ["Exercise Name 1", "Exercise Name 2"],
                  "setsPerExercise": 3,
                  "notes": "Brief notes about this day"
                }
              ]
            }
            Use common exercise names. Create one routine per training day. Include 4-6 exercises per routine. Match the plan to the user's experience level and goals.
            """,
            "messages": [
                ["role": "user", "content": userPrompt]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClaudeError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if let errorJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMsg = (errorJSON["error"] as? [String: Any])?["message"] as? String {
                throw ClaudeError.apiError(errorMsg)
            }
            throw ClaudeError.apiError("HTTP \(httpResponse.statusCode)")
        }

        // Parse Anthropic response
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let firstBlock = content.first,
              let text = firstBlock["text"] as? String else {
            throw ClaudeError.invalidResponse
        }

        // Extract JSON from response (Claude might wrap it in markdown code blocks)
        let jsonString = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw ClaudeError.invalidResponse
        }

        return try JSONDecoder().decode(GeneratedWorkoutPlan.self, from: jsonData)
    }

    // MARK: - Analyze Food Description

    func analyzeFoodDescription(_ text: String) async throws -> NutritionData {
        let apiKey = AppConstants.anthropicAPIKey
        guard !apiKey.isEmpty else { throw ClaudeError.noAPIKey }

        guard let url = URL(string: AppConstants.anthropicBaseURL) else {
            throw ClaudeError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": AppConstants.anthropicModel,
            "max_tokens": 1024,
            "system": "You are a nutrition expert. Given a food description, estimate the nutrition. Respond ONLY with valid JSON in this exact format, no other text: {\"name\":\"...\",\"calories\":0,\"proteinG\":0.0,\"carbsG\":0.0,\"fatG\":0.0,\"servingSize\":\"...\"}",
            "messages": [
                ["role": "user", "content": text]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClaudeError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if let errorJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMsg = (errorJSON["error"] as? [String: Any])?["message"] as? String {
                throw ClaudeError.apiError(errorMsg)
            }
            throw ClaudeError.apiError("HTTP \(httpResponse.statusCode)")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let firstBlock = content.first,
              let responseText = firstBlock["text"] as? String else {
            throw ClaudeError.invalidResponse
        }

        let jsonString = responseText
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw ClaudeError.invalidResponse
        }

        return try JSONDecoder().decode(NutritionData.self, from: jsonData)
    }

    // MARK: - Refine Workout Plan

    func refineWorkoutPlan(
        currentPlan: GeneratedWorkoutPlan,
        refinement: String,
        history: [ConversationMessage]
    ) async throws -> GeneratedWorkoutPlan {
        let apiKey = AppConstants.anthropicAPIKey
        guard !apiKey.isEmpty else { throw ClaudeError.noAPIKey }

        guard let url = URL(string: AppConstants.anthropicBaseURL) else {
            throw ClaudeError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let planJSON = try JSONEncoder().encode(currentPlan)
        let planString = String(data: planJSON, encoding: .utf8) ?? "{}"

        let userMessage = """
        Current workout plan:
        \(planString)

        Refinement request: \(refinement)
        """

        var messages: [[String: String]] = history.map { ["role": $0.role, "content": $0.content] }
        messages.append(["role": "user", "content": userMessage])

        let body: [String: Any] = [
            "model": AppConstants.anthropicModel,
            "max_tokens": 2048,
            "system": """
            You are a certified personal trainer refining workout plans. The user will provide their current plan and a refinement request. Apply the requested changes and respond ONLY with valid JSON in this exact format, no other text:
            {
              "routines": [
                {
                  "name": "Day Name",
                  "exercises": ["Exercise 1", "Exercise 2"],
                  "setsPerExercise": 3,
                  "notes": "Brief notes"
                }
              ]
            }
            Keep exercises realistic and match the user's intent.
            """,
            "messages": messages
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClaudeError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if let errorJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMsg = (errorJSON["error"] as? [String: Any])?["message"] as? String {
                throw ClaudeError.apiError(errorMsg)
            }
            throw ClaudeError.apiError("HTTP \(httpResponse.statusCode)")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let firstBlock = content.first,
              let text = firstBlock["text"] as? String else {
            throw ClaudeError.invalidResponse
        }

        let jsonString = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw ClaudeError.invalidResponse
        }

        return try JSONDecoder().decode(GeneratedWorkoutPlan.self, from: jsonData)
    }

    // MARK: - Calculate Nutrition Goals

    func calculateNutritionGoals(
        gender: String,
        age: Int,
        heightCM: Double,
        weightKG: Double,
        activityLevel: String,
        goal: String
    ) async throws -> NutritionGoals {
        let apiKey = AppConstants.anthropicAPIKey
        guard !apiKey.isEmpty else { throw ClaudeError.noAPIKey }

        guard let url = URL(string: AppConstants.anthropicBaseURL) else {
            throw ClaudeError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let userPrompt = """
        Calculate daily nutrition targets for:
        - Gender: \(gender)
        - Age: \(age)
        - Height: \(heightCM) cm
        - Weight: \(weightKG) kg
        - Activity level: \(activityLevel)
        - Goal: \(goal)
        """

        let body: [String: Any] = [
            "model": AppConstants.anthropicModel,
            "max_tokens": 1024,
            "system": "You are a certified nutritionist. Calculate daily calorie and macro targets. Respond ONLY with JSON: {\"calories\":0,\"proteinG\":0,\"carbsG\":0,\"fatG\":0,\"reasoning\":\"...\"}",
            "messages": [
                ["role": "user", "content": userPrompt]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClaudeError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if let errorJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMsg = (errorJSON["error"] as? [String: Any])?["message"] as? String {
                throw ClaudeError.apiError(errorMsg)
            }
            throw ClaudeError.apiError("HTTP \(httpResponse.statusCode)")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let firstBlock = content.first,
              let text = firstBlock["text"] as? String else {
            throw ClaudeError.invalidResponse
        }

        let jsonString = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw ClaudeError.invalidResponse
        }

        return try JSONDecoder().decode(NutritionGoals.self, from: jsonData)
    }
}
