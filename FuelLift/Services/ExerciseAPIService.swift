import Foundation

final class ExerciseAPIService {
    static let shared = ExerciseAPIService()
    private init() {}

    private var imageCache: [String: URL] = [:]
    private let baseURL = "https://wger.de/api/v2"

    // MARK: - Exercise ID Map (wger.de IDs)

    private let exerciseIDMap: [String: Int] = [
        "bench press": 192,
        "squat": 289,
        "deadlift": 105,
        "overhead press": 119,
        "barbell row": 106,
        "pull up": 107,
        "lat pulldown": 108,
        "dumbbell curl": 81,
        "tricep pushdown": 92,
        "leg press": 115,
        "leg curl": 113,
        "leg extension": 110,
        "calf raise": 104,
        "dumbbell lateral raise": 148,
        "face pull": 670,
        "cable fly": 150,
        "incline dumbbell press": 163,
        "dumbbell row": 362,
        "romanian deadlift": 116,
        "hip thrust": 766,
        "plank": 238,
        "russian twist": 826,
        "cable crunch": 172,
        "dumbbell shoulder press": 123,
        "hammer curl": 82,
        "skull crusher": 386,
        "preacher curl": 84,
        "chest dip": 99,
        "close grip bench press": 217,
    ]

    // MARK: - Response Types

    struct SearchResponse: Codable {
        let suggestions: [Suggestion]
    }
    struct Suggestion: Codable {
        let data: SuggestionData
    }
    struct SuggestionData: Codable {
        let id: Int
        let name: String
        let image: String?
        let image_thumbnail: String?
    }
    struct ExerciseInfoResponse: Codable {
        let images: [ExerciseImage]
    }
    struct ExerciseImage: Codable {
        let image: String
        let is_main: Bool
    }

    // MARK: - Public API

    func fetchExerciseImageURL(for exerciseName: String) async -> URL? {
        let key = exerciseName.lowercased()

        // 1. Check cache
        if let cached = imageCache[key] { return cached }

        // 2. Try direct ID lookup first
        if let wgerID = exerciseIDMap[key] {
            print("[ExerciseAPI] Found ID \(wgerID) for '\(exerciseName)', fetching directly")
            if let url = await fetchExerciseImageByID(wgerID) {
                imageCache[key] = url
                return url
            }
        }

        // 3. Fallback: search wger by exercise name
        print("[ExerciseAPI] Searching wger for '\(exerciseName)'")
        let query = exerciseName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? exerciseName
        guard let searchURL = URL(string: "\(baseURL)/exercise/search/?term=\(query)&language=2&format=json") else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: searchURL)
            let response = try JSONDecoder().decode(SearchResponse.self, from: data)
            guard let first = response.suggestions.first else {
                print("[ExerciseAPI] No search results for '\(exerciseName)'")
                return nil
            }

            // Check if search result has image directly
            if let imageStr = first.data.image, let url = URL(string: imageStr.hasPrefix("http") ? imageStr : "https://wger.de\(imageStr)") {
                imageCache[key] = url
                print("[ExerciseAPI] Found image from search for '\(exerciseName)'")
                return url
            }

            // 4. Fetch exercise info for images
            if let url = await fetchExerciseImageByID(first.data.id) {
                imageCache[key] = url
                return url
            }
        } catch {
            print("[ExerciseAPI] Error fetching image for '\(exerciseName)': \(error.localizedDescription)")
        }
        return nil
    }

    // MARK: - Private

    private func fetchExerciseImageByID(_ id: Int) async -> URL? {
        guard let infoURL = URL(string: "\(baseURL)/exerciseinfo/\(id)/?format=json") else { return nil }

        do {
            let (infoData, _) = try await URLSession.shared.data(from: infoURL)
            let infoResponse = try JSONDecoder().decode(ExerciseInfoResponse.self, from: infoData)

            if let mainImage = infoResponse.images.first(where: { $0.is_main }) ?? infoResponse.images.first {
                let imageURL = URL(string: mainImage.image.hasPrefix("http") ? mainImage.image : "https://wger.de\(mainImage.image)")
                print("[ExerciseAPI] Found image for ID \(id)")
                return imageURL
            } else {
                print("[ExerciseAPI] No images found for ID \(id)")
            }
        } catch {
            print("[ExerciseAPI] Error fetching info for ID \(id): \(error.localizedDescription)")
        }
        return nil
    }
}
