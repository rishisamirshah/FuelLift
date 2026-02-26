import Foundation
import SwiftData

@Model
final class ExerciseSet {
    var id: String
    var exerciseName: String
    var setNumber: Int
    var weight: Double   // in kg or lbs based on user pref
    var reps: Int
    var rpe: Double?     // Rate of Perceived Exertion (1-10)
    var isWarmup: Bool
    var isCompleted: Bool
    var timestamp: Date

    // PR tracking
    var isPersonalRecord: Bool

    init(
        exerciseName: String,
        setNumber: Int,
        weight: Double = 0,
        reps: Int = 0,
        rpe: Double? = nil,
        isWarmup: Bool = false
    ) {
        self.id = UUID().uuidString
        self.exerciseName = exerciseName
        self.setNumber = setNumber
        self.weight = weight
        self.reps = reps
        self.rpe = rpe
        self.isWarmup = isWarmup
        self.isCompleted = false
        self.isPersonalRecord = false
        self.timestamp = Date()
    }

    // Estimated 1RM using Epley formula
    var estimated1RM: Double {
        guard reps > 0, weight > 0 else { return 0 }
        if reps == 1 { return weight }
        return weight * (1 + Double(reps) / 30.0)
    }

    var volume: Double {
        weight * Double(reps)
    }

    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "exerciseName": exerciseName,
            "setNumber": setNumber,
            "weight": weight,
            "reps": reps,
            "isWarmup": isWarmup,
            "isCompleted": isCompleted,
            "isPersonalRecord": isPersonalRecord
        ]
        if let rpe { data["rpe"] = rpe }
        return data
    }
}
