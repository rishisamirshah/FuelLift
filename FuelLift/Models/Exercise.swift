import Foundation
import SwiftData

@Model
final class Exercise {
    var id: String
    var name: String
    var muscleGroup: String
    var equipment: String
    var instructions: String
    var isCustom: Bool

    init(
        name: String,
        muscleGroup: String = "",
        equipment: String = "Barbell",
        instructions: String = "",
        isCustom: Bool = false
    ) {
        self.id = UUID().uuidString
        self.name = name
        self.muscleGroup = muscleGroup
        self.equipment = equipment
        self.instructions = instructions
        self.isCustom = isCustom
    }
}

// Static exercise data loaded from JSON
struct ExerciseDefinition: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let muscleGroup: String
    let equipment: String
    let instructions: String

    static func loadAll() -> [ExerciseDefinition] {
        guard let url = Bundle.main.url(forResource: "ExerciseLibrary", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let exercises = try? JSONDecoder().decode([ExerciseDefinition].self, from: data) else {
            return defaultExercises
        }
        return exercises
    }

    static let defaultExercises: [ExerciseDefinition] = [
        // Chest
        ExerciseDefinition(id: "bench-press", name: "Bench Press", muscleGroup: "Chest", equipment: "Barbell", instructions: "Lie on bench, grip bar shoulder-width, lower to chest, press up."),
        ExerciseDefinition(id: "incline-bench", name: "Incline Bench Press", muscleGroup: "Chest", equipment: "Barbell", instructions: "Set bench to 30-45°, press bar from upper chest."),
        ExerciseDefinition(id: "db-bench", name: "Dumbbell Bench Press", muscleGroup: "Chest", equipment: "Dumbbell", instructions: "Lie on bench with dumbbells, press up and together."),
        ExerciseDefinition(id: "chest-fly", name: "Cable Fly", muscleGroup: "Chest", equipment: "Cable", instructions: "Stand between cables, bring hands together in front of chest."),
        ExerciseDefinition(id: "push-up", name: "Push Up", muscleGroup: "Chest", equipment: "Bodyweight", instructions: "Hands shoulder-width, lower chest to floor, push up."),
        // Back
        ExerciseDefinition(id: "deadlift", name: "Deadlift", muscleGroup: "Back", equipment: "Barbell", instructions: "Stand over bar, hinge at hips, grip bar, drive through legs."),
        ExerciseDefinition(id: "barbell-row", name: "Barbell Row", muscleGroup: "Back", equipment: "Barbell", instructions: "Hinge forward, pull bar to lower chest, squeeze shoulder blades."),
        ExerciseDefinition(id: "pull-up", name: "Pull Up", muscleGroup: "Back", equipment: "Bodyweight", instructions: "Hang from bar, pull chin above bar."),
        ExerciseDefinition(id: "lat-pulldown", name: "Lat Pulldown", muscleGroup: "Back", equipment: "Cable", instructions: "Grip wide bar, pull to upper chest, control back up."),
        ExerciseDefinition(id: "seated-row", name: "Seated Cable Row", muscleGroup: "Back", equipment: "Cable", instructions: "Sit upright, pull handle to torso, squeeze back."),
        // Shoulders
        ExerciseDefinition(id: "ohp", name: "Overhead Press", muscleGroup: "Shoulders", equipment: "Barbell", instructions: "Press bar from front of shoulders overhead to lockout."),
        ExerciseDefinition(id: "lateral-raise", name: "Lateral Raise", muscleGroup: "Shoulders", equipment: "Dumbbell", instructions: "Arms at sides, raise dumbbells to shoulder height."),
        ExerciseDefinition(id: "face-pull", name: "Face Pull", muscleGroup: "Shoulders", equipment: "Cable", instructions: "Pull rope to face, external rotate at top."),
        // Legs
        ExerciseDefinition(id: "squat", name: "Squat", muscleGroup: "Legs", equipment: "Barbell", instructions: "Bar on upper back, squat to parallel, drive up."),
        ExerciseDefinition(id: "leg-press", name: "Leg Press", muscleGroup: "Legs", equipment: "Machine", instructions: "Feet shoulder-width on platform, lower and press."),
        ExerciseDefinition(id: "romanian-dl", name: "Romanian Deadlift", muscleGroup: "Legs", equipment: "Barbell", instructions: "Hinge at hips with slight knee bend, feel hamstring stretch."),
        ExerciseDefinition(id: "leg-curl", name: "Leg Curl", muscleGroup: "Legs", equipment: "Machine", instructions: "Lie face down, curl weight toward glutes."),
        ExerciseDefinition(id: "leg-extension", name: "Leg Extension", muscleGroup: "Legs", equipment: "Machine", instructions: "Sit upright, extend legs to straighten knees."),
        ExerciseDefinition(id: "calf-raise", name: "Calf Raise", muscleGroup: "Legs", equipment: "Machine", instructions: "Rise onto toes, pause at top, lower slowly."),
        // Arms
        ExerciseDefinition(id: "barbell-curl", name: "Barbell Curl", muscleGroup: "Arms", equipment: "Barbell", instructions: "Curl bar up keeping elbows pinned to sides."),
        ExerciseDefinition(id: "tricep-pushdown", name: "Tricep Pushdown", muscleGroup: "Arms", equipment: "Cable", instructions: "Push cable down, lock out elbows, control back up."),
        ExerciseDefinition(id: "hammer-curl", name: "Hammer Curl", muscleGroup: "Arms", equipment: "Dumbbell", instructions: "Curl dumbbells with neutral grip (palms facing in)."),
        ExerciseDefinition(id: "skull-crusher", name: "Skull Crusher", muscleGroup: "Arms", equipment: "Barbell", instructions: "Lie on bench, lower bar to forehead, extend arms."),
        // Core
        ExerciseDefinition(id: "plank", name: "Plank", muscleGroup: "Core", equipment: "Bodyweight", instructions: "Hold push-up position on forearms. Keep body straight."),
        ExerciseDefinition(id: "cable-crunch", name: "Cable Crunch", muscleGroup: "Core", equipment: "Cable", instructions: "Kneel at cable, crunch down bringing elbows to knees."),
        ExerciseDefinition(id: "hanging-leg-raise", name: "Hanging Leg Raise", muscleGroup: "Core", equipment: "Bodyweight", instructions: "Hang from bar, raise legs to parallel."),
    ]

    static let muscleGroups = ["Chest", "Back", "Shoulders", "Legs", "Arms", "Core"]
    static let equipmentTypes = ["Barbell", "Dumbbell", "Cable", "Machine", "Bodyweight"]
}
