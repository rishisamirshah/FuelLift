import Foundation
import SwiftData

@Model
final class WorkoutRoutine {
    var id: String
    var name: String
    var exerciseNamesData: Data?
    var defaultSetsPerExercise: Int
    var notes: String
    var createdAt: Date
    var lastUsedAt: Date?

    var exerciseNames: [String] {
        get {
            guard let data = exerciseNamesData else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            exerciseNamesData = try? JSONEncoder().encode(newValue)
        }
    }

    init(name: String, exerciseNames: [String] = [], defaultSets: Int = 3) {
        self.id = UUID().uuidString
        self.name = name
        self.defaultSetsPerExercise = defaultSets
        self.notes = ""
        self.createdAt = Date()
        self.exerciseNamesData = try? JSONEncoder().encode(exerciseNames)
    }
}
