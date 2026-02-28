import SwiftUI
import SwiftData

struct RoutineEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var existingRoutine: WorkoutRoutine?

    @State private var name = ""
    @State private var selectedExercises: [String] = []
    @State private var defaultSets = 3
    @State private var notes = ""
    @State private var showExercisePicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacingLG) {
                    // Name field
                    VStack(alignment: .leading, spacing: Theme.spacingSM) {
                        Text("Routine Name")
                            .font(.system(size: Theme.captionSize, weight: .semibold))
                            .foregroundStyle(Color.appTextSecondary)

                        TextField("e.g. Push Day", text: $name)
                            .font(.system(size: Theme.bodySize))
                            .padding(Theme.spacingMD)
                            .background(Color.appCardSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSM))
                    }
                    .cardStyle()

                    // Settings
                    VStack(spacing: Theme.spacingSM) {
                        HStack {
                            Text("Default Sets")
                                .font(.system(size: Theme.bodySize))
                                .foregroundStyle(Color.appTextPrimary)
                            Spacer()
                            Stepper("\(defaultSets)", value: $defaultSets, in: 1...10)
                                .labelsHidden()
                            Text("\(defaultSets)")
                                .font(.system(size: Theme.bodySize, weight: .bold))
                                .foregroundStyle(Color.appTextPrimary)
                                .frame(width: 24)
                        }

                        Divider()

                        VStack(alignment: .leading, spacing: Theme.spacingSM) {
                            Text("Notes")
                                .font(.system(size: Theme.captionSize, weight: .semibold))
                                .foregroundStyle(Color.appTextSecondary)

                            TextField("Optional notes...", text: $notes, axis: .vertical)
                                .font(.system(size: Theme.bodySize))
                                .lineLimit(3...6)
                        }
                    }
                    .cardStyle()

                    // Exercises
                    VStack(alignment: .leading, spacing: Theme.spacingSM) {
                        HStack {
                            Text("Exercises")
                                .font(.system(size: Theme.subheadlineSize, weight: .bold))
                                .foregroundStyle(Color.appTextPrimary)

                            Text("(\(selectedExercises.count))")
                                .font(.system(size: Theme.captionSize))
                                .foregroundStyle(Color.appTextSecondary)

                            Spacer()
                        }

                        if selectedExercises.isEmpty {
                            Text("No exercises added yet.")
                                .font(.system(size: Theme.captionSize))
                                .foregroundStyle(Color.appTextTertiary)
                                .padding(.vertical, Theme.spacingMD)
                        } else {
                            ForEach(selectedExercises.indices, id: \.self) { index in
                                HStack(spacing: Theme.spacingMD) {
                                    Image(systemName: "line.3.horizontal")
                                        .foregroundStyle(Color.appTextTertiary)
                                        .font(.system(size: Theme.captionSize))

                                    Text(selectedExercises[index])
                                        .font(.system(size: Theme.bodySize))
                                        .foregroundStyle(Color.appTextPrimary)

                                    Spacer()

                                    Button {
                                        selectedExercises.remove(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(Color.appTextTertiary)
                                    }
                                }
                                .padding(.vertical, Theme.spacingXS)

                                if index < selectedExercises.count - 1 {
                                    Divider()
                                }
                            }
                        }

                        Button {
                            showExercisePicker = true
                        } label: {
                            HStack(spacing: Theme.spacingSM) {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Exercise")
                            }
                            .font(.system(size: Theme.captionSize, weight: .semibold))
                            .foregroundStyle(Color.appAccent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.spacingSM)
                        }
                    }
                    .cardStyle()
                }
                .padding(.horizontal, Theme.spacingLG)
                .padding(.top, Theme.spacingSM)
            }
            .screenBackground()
            .navigationTitle(existingRoutine != nil ? "Edit Routine" : "New Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveRoutine() }
                        .bold()
                        .foregroundStyle(Color.appAccent)
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
            .onAppear { loadExistingRoutine() }
        }
    }

    private func saveRoutine() {
        if let existing = existingRoutine {
            existing.name = name
            existing.exerciseNames = selectedExercises
            existing.defaultSetsPerExercise = defaultSets
            existing.notes = notes
            existing.lastUsedAt = Date()
        } else {
            let routine = WorkoutRoutine(
                name: name,
                exerciseNames: selectedExercises,
                defaultSets: defaultSets
            )
            routine.notes = notes
            modelContext.insert(routine)
        }
        try? modelContext.save()
        dismiss()
    }

    private func loadExistingRoutine() {
        if let routine = existingRoutine {
            name = routine.name
            selectedExercises = routine.exerciseNames
            defaultSets = routine.defaultSetsPerExercise
            notes = routine.notes
        }
    }
}
