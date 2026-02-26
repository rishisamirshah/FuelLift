import Foundation
import SwiftData

@Model
final class WorkoutRoutine {
    var id: String
    var name: String
    var exerciseNames: [String]
    var defaultSetsPerExercise: Int
    var notes: String
    var createdAt: Date
    var lastUsedAt: Date?

    init(name: String, exerciseNames: [String] = [], defaultSets: Int = 3) {
        self.id = UUID().uuidString
        self.name = name
        self.exerciseNames = exerciseNames
        self.defaultSetsPerExercise = defaultSets
        self.notes = ""
        self.createdAt = Date()
    }
}
