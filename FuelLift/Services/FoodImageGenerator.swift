import SwiftUI

/// Generates realistic food images using Gemini's image generation API
/// and caches them locally on disk. Falls back to emoji placeholder while generating.
final class FoodImageGenerator {
    static let shared = FoodImageGenerator()
    private init() {
        createCacheDirectoryIfNeeded()
    }

    /// Tracks in-flight generation tasks to avoid duplicate requests
    private var inFlightTasks: [String: Task<UIImage?, Never>] = [:]

    // MARK: - Public

    /// Returns a cached food image for the given item name, or nil if not yet generated.
    /// Call `generateIfNeeded` to trigger background generation.
    func cachedImage(for itemName: String) -> UIImage? {
        let key = cacheKey(for: itemName)
        let fileURL = cacheFileURL(for: key)

        guard FileManager.default.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }

        return image
    }

    /// Generates a food image if not already cached. Returns the generated image.
    func generateIfNeeded(for itemName: String) async -> UIImage? {
        let key = cacheKey(for: itemName)

        // Already cached
        if let cached = cachedImage(for: itemName) {
            return cached
        }

        // Already generating
        if let existing = inFlightTasks[key] {
            return await existing.value
        }

        let task = Task<UIImage?, Never> {
            let image = await generateFoodImage(for: itemName)
            if let image, let data = image.pngData() {
                let fileURL = cacheFileURL(for: key)
                try? data.write(to: fileURL)
            }
            return image
        }

        inFlightTasks[key] = task
        let result = await task.value
        inFlightTasks.removeValue(forKey: key)
        return result
    }

    // MARK: - Gemini Image Generation

    private func generateFoodImage(for itemName: String) async -> UIImage? {
        let apiKey = AppConstants.geminiAPIKey
        guard !apiKey.isEmpty, !apiKey.contains("$(") else { return nil }

        let prompt = FoodCategoryMapper.imagePrompt(for: itemName)
            + " No text, no watermarks, no labels."

        let body: [String: Any] = [
            "contents": [["parts": [["text": prompt]]]],
            "generationConfig": [
                "responseModalities": ["IMAGE", "TEXT"],
                "imageMimeType": "image/png"
            ]
        ]

        // Use gemini-2.0-flash for image generation (proven image gen support)
        let urlString = "\(AppConstants.geminiBaseURL)/gemini-2.0-flash-exp:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return nil
        }

        // Parse response — look for inlineData with image
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]] else {
            return nil
        }

        // Find the image part
        for part in parts {
            if let inlineData = part["inlineData"] as? [String: Any],
               let base64String = inlineData["data"] as? String,
               let imageData = Data(base64Encoded: base64String),
               let image = UIImage(data: imageData) {
                // Resize to a reasonable thumbnail size
                return resizeImage(image, to: CGSize(width: 256, height: 256))
            }
        }

        return nil
    }

    // MARK: - Cache Helpers

    private var cacheDirectory: URL {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return caches.appendingPathComponent("FoodImages", isDirectory: true)
    }

    private func createCacheDirectoryIfNeeded() {
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    private func cacheKey(for itemName: String) -> String {
        // Map to food category first so similar items share the same image
        let category = FoodCategoryMapper.categoryKey(for: itemName)
        return category
    }

    private func cacheFileURL(for key: String) -> URL {
        cacheDirectory.appendingPathComponent("\(key).png")
    }

    // MARK: - Image Utilities

    private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
