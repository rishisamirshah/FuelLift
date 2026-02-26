import SwiftUI

@MainActor
final class ExerciseLibraryViewModel: ObservableObject {
    @Published var exercises: [ExerciseDefinition] = []
    @Published var searchText = ""
    @Published var selectedMuscleGroup: String?

    var filteredExercises: [ExerciseDefinition] {
        var result = exercises

        if let group = selectedMuscleGroup {
            result = result.filter { $0.muscleGroup == group }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.muscleGroup.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    init() {
        exercises = ExerciseDefinition.loadAll()
    }
}
