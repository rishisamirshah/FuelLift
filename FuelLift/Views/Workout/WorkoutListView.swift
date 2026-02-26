import SwiftUI
import SwiftData

struct WorkoutListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]
    @Query(sort: \WorkoutRoutine.lastUsedAt, order: .reverse) private var routines: [WorkoutRoutine]
    @StateObject private var workoutVM = WorkoutViewModel()
    @State private var showActiveWorkout = false
    @State private var showRoutineEditor = false
    @State private var showExercisePicker = false

    var body: some View {
        NavigationStack {
            List {
                // Quick start
                Section {
                    Button {
                        workoutVM.startWorkout(name: "Quick Workout")
                        showActiveWorkout = true
                    } label: {
                        Label("Start Empty Workout", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .foregroundStyle(.orange)
                    }
                }

                // Routines
                if !routines.isEmpty {
                    Section("Routines") {
                        ForEach(routines, id: \.id) { routine in
                            Button {
                                workoutVM.startWorkout(name: routine.name, from: routine)
                                routine.lastUsedAt = Date()
                                showActiveWorkout = true
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(routine.name)
                                        .font(.subheadline.bold())
                                    Text(routine.exerciseNames.joined(separator: ", "))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            .buttonStyle(.plain)
                        }

                        Button {
                            showRoutineEditor = true
                        } label: {
                            Label("New Routine", systemImage: "plus")
                                .font(.subheadline)
                        }
                    }
                }

                // History
                Section("History") {
                    if workouts.isEmpty {
                        Text("No workouts yet. Start your first one!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(workouts, id: \.id) { workout in
                            workoutRow(workout)
                        }
                    }
                }
            }
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showRoutineEditor = true } label: {
                        Image(systemName: "list.bullet.rectangle.portrait")
                    }
                }
            }
            .fullScreenCover(isPresented: $showActiveWorkout) {
                ActiveWorkoutView(viewModel: workoutVM)
            }
            .sheet(isPresented: $showRoutineEditor) {
                RoutineEditorView()
            }
        }
    }

    private func workoutRow(_ workout: Workout) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(workout.name)
                    .font(.subheadline.bold())
                Spacer()
                Text(workout.date.shortFormatted)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 12) {
                Label(workout.durationFormatted, systemImage: "clock")
                Label("\(workout.totalSets) sets", systemImage: "number")
                Label("\(Int(workout.totalVolume)) kg", systemImage: "scalemass")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if !workout.exerciseNames.isEmpty {
                Text(workout.exerciseNames.joined(separator: " · "))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 2)
    }
}
