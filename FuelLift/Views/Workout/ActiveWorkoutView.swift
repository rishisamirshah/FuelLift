import SwiftUI

struct ActiveWorkoutView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showExercisePicker = false
    @State private var showFinishConfirm = false
    @State private var showCancelConfirm = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 16) {
                        // Timer bar
                        HStack {
                            Image(systemName: "timer")
                            Text(viewModel.elapsedFormatted)
                                .font(.title3.monospacedDigit().bold())
                            Spacer()
                        }
                        .padding(.horizontal)

                        // PR alerts
                        ForEach(viewModel.newPRs, id: \.self) { exerciseName in
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .foregroundStyle(.yellow)
                                Text("New PR on \(exerciseName)!")
                                    .font(.subheadline.bold())
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(.yellow.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)
                        }

                        // Exercise groups
                        ForEach(viewModel.exerciseGroups.indices, id: \.self) { groupIndex in
                            exerciseGroupCard(groupIndex: groupIndex)
                        }

                        // Add exercise button
                        Button {
                            showExercisePicker = true
                        } label: {
                            Label("Add Exercise", systemImage: "plus.circle.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.horizontal)

                        Spacer(minLength: 100)
                    }
                    .padding(.top)
                }

                // Rest timer overlay
                if viewModel.showRestTimer {
                    RestTimerView(viewModel: viewModel)
                        .transition(.move(edge: .bottom))
                }
            }
            .navigationTitle(viewModel.activeWorkout?.name ?? "Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { showCancelConfirm = true }
                        .foregroundStyle(.red)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Finish") { showFinishConfirm = true }
                        .bold()
                }
            }
            .sheet(isPresented: $showExercisePicker) {
                ExercisePickerView { exerciseName in
                    viewModel.addExercise(name: exerciseName)
                }
            }
            .alert("Finish Workout?", isPresented: $showFinishConfirm) {
                Button("Finish", role: .destructive) {
                    viewModel.finishWorkout(context: modelContext)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Save this workout with \(viewModel.exerciseGroups.count) exercises?")
            }
            .alert("Discard Workout?", isPresented: $showCancelConfirm) {
                Button("Discard", role: .destructive) {
                    viewModel.cancelWorkout()
                    dismiss()
                }
                Button("Keep Going", role: .cancel) {}
            }
        }
    }

    // MARK: - Exercise Group Card

    private func exerciseGroupCard(groupIndex: Int) -> some View {
        let group = viewModel.exerciseGroups[groupIndex]

        return VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text(group.exerciseName)
                    .font(.headline)
                Spacer()
                Button {
                    viewModel.removeExercise(at: groupIndex)
                } label: {
                    Image(systemName: "xmark.circle")
                        .foregroundStyle(.secondary)
                }
            }

            // Set headers
            HStack {
                Text("SET").frame(width: 35)
                Text("PREV").frame(maxWidth: .infinity)
                Text("KG").frame(width: 70)
                Text("REPS").frame(width: 60)
                Text("").frame(width: 40) // checkmark
            }
            .font(.caption2.bold())
            .foregroundStyle(.secondary)

            // Sets
            ForEach(group.sets.indices, id: \.self) { setIndex in
                setRow(groupIndex: groupIndex, setIndex: setIndex)
            }

            // Add set button
            Button {
                viewModel.addSet(to: groupIndex)
            } label: {
                Label("Add Set", systemImage: "plus")
                    .font(.caption)
            }
        }
        .cardStyle()
        .padding(.horizontal)
    }

    private func setRow(groupIndex: Int, setIndex: Int) -> some View {
        let set = viewModel.exerciseGroups[groupIndex].sets[setIndex]

        return HStack {
            // Set number
            Text(set.isWarmup ? "W" : "\(set.setNumber)")
                .font(.subheadline)
                .foregroundStyle(set.isWarmup ? .orange : .primary)
                .frame(width: 35)

            // Previous (placeholder)
            Text("-")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity)

            // Weight
            TextField("0", value: $viewModel.exerciseGroups[groupIndex].sets[setIndex].weight, format: .number)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 70)

            // Reps
            TextField("0", value: $viewModel.exerciseGroups[groupIndex].sets[setIndex].reps, format: .number)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 60)

            // Complete button
            Button {
                viewModel.completeSet(groupIndex: groupIndex, setIndex: setIndex, context: modelContext)
            } label: {
                Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(set.isCompleted ? (set.isPersonalRecord ? .yellow : .green) : .secondary)
                    .font(.title3)
            }
            .frame(width: 40)
            .disabled(set.isCompleted)
        }
        .font(.subheadline)
    }
}
