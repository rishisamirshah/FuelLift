import Foundation
import SwiftData

@Model
final class Workout {
    var id: String
    var name: String
    var date: Date
    var durationSeconds: Int
    var notes: String
    var isCompleted: Bool
    var firestoreId: String?

    // Store exercises as JSON for flexibility with supersets
    var exerciseGroupsData: Data?

    init(
        name: String = "Workout",
        date: Date = Date()
    ) {
        self.id = UUID().uuidString
        self.name = name
        self.date = date
        self.durationSeconds = 0
        self.notes = ""
        self.isCompleted = false
    }

    var totalVolume: Double {
        let groups = decodeExerciseGroups()
        return groups.flatMap(\.sets).reduce(0) { $0 + $1.volume }
    }

    var totalSets: Int {
        let groups = decodeExerciseGroups()
        return groups.flatMap(\.sets).filter { !$0.isWarmup && $0.isCompleted }.count
    }

    var exerciseNames: [String] {
        decodeExerciseGroups().map(\.exerciseName)
    }

    var durationFormatted: String {
        let hours = durationSeconds / 3600
        let minutes = (durationSeconds % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "name": name,
            "date": date,
            "durationSeconds": durationSeconds,
            "notes": notes,
            "isCompleted": isCompleted,
            "totalVolume": totalVolume,
            "totalSets": totalSets,
            "exerciseNames": exerciseNames
        ]
        if let groupsData = exerciseGroupsData {
            data["exerciseGroupsData"] = groupsData.base64EncodedString()
        }
        return data
    }

    // MARK: - Exercise Groups

    func decodeExerciseGroups() -> [WorkoutExerciseGroup] {
        guard let data = exerciseGroupsData else { return [] }
        return (try? JSONDecoder().decode([WorkoutExerciseGroup].self, from: data)) ?? []
    }

    func encodeExerciseGroups(_ groups: [WorkoutExerciseGroup]) {
        exerciseGroupsData = try? JSONEncoder().encode(groups)
    }
}

// Codable wrapper for exercise data within a workout
struct WorkoutExerciseGroup: Codable, Identifiable {
    let id: String
    var exerciseName: String
    var sets: [WorkoutSetData]
    var isSuperset: Bool
    var supersetPartnerIds: [String]

    init(exerciseName: String) {
        self.id = UUID().uuidString
        self.exerciseName = exerciseName
        self.sets = [WorkoutSetData(setNumber: 1)]
        self.isSuperset = false
        self.supersetPartnerIds = []
    }
}

struct WorkoutSetData: Codable, Identifiable {
    let id: String
    var setNumber: Int
    var weight: Double
    var reps: Int
    var rpe: Double?
    var isWarmup: Bool
    var isCompleted: Bool
    var isPersonalRecord: Bool

    init(setNumber: Int, weight: Double = 0, reps: Int = 0, isWarmup: Bool = false) {
        self.id = UUID().uuidString
        self.setNumber = setNumber
        self.weight = weight
        self.reps = reps
        self.isWarmup = isWarmup
        self.isCompleted = false
        self.isPersonalRecord = false
    }

    var volume: Double { weight * Double(reps) }

    var estimated1RM: Double {
        guard reps > 0, weight > 0 else { return 0 }
        if reps == 1 { return weight }
        return weight * (1 + Double(reps) / 30.0)
    }
}
