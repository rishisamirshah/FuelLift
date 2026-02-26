import SwiftUI
import SwiftData

struct RoutineEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedExercises: [String] = []
    @State private var defaultSets = 3
    @State private var notes = ""
    @State private var showExercisePicker = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Routine name (e.g. Push Day)", text: $name)

                    Stepper("Default sets: \(defaultSets)", value: $defaultSets, in: 1...10)

                    TextField("Notes (optional)", text: $notes)
                }

                Section("Exercises (\(selectedExercises.count))") {
                    ForEach(selectedExercises, id: \.self) { exercise in
                        Text(exercise)
                    }
                    .onDelete { indices in
                        selectedExercises.remove(atOffsets: indices)
                    }
                    .onMove { source, destination in
                        selectedExercises.move(fromOffsets: source, toOffset: destination)
                    }

                    Button {
                        showExercisePicker = true
                    } label: {
                        Label("Add Exercise", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("New Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveRoutine() }
                        .bold()
                        .disabled(name.isEmpty || selectedExercises.isEmpty)
                }
            }
            .sheet(isPresented: $showExercisePicker) {
                ExercisePickerView { exerciseName in
                    if !selectedExercises.contains(exerciseName) {
                        selectedExercises.append(exerciseName)
                    }
                }
            }
        }
    }

    private func saveRoutine() {
        let routine = WorkoutRoutine(
            name: name,
            exerciseNames: selectedExercises,
            defaultSets: defaultSets
        )
        routine.notes = notes
        modelContext.insert(routine)
        try? modelContext.save()
        dismiss()
    }
}
