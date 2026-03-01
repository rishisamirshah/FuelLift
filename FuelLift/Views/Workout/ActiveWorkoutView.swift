import SwiftUI

struct ActiveWorkoutView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showExercisePicker = false
    @State private var showFinishConfirm = false
    @State private var showCancelConfirm = false
    @State private var showCompletion = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: Theme.spacingLG) {
                        // Timer bar
                        HStack(spacing: Theme.spacingSM) {
                            Image("icon_timer")
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: 20, height: 20)
                            Text(viewModel.elapsedFormatted)
                                .font(.system(size: Theme.subheadlineSize, weight: .bold, design: .monospaced))
                                .foregroundStyle(Color.appTextPrimary)
                            Spacer()
                        }
                        .padding(.horizontal, Theme.spacingLG)

                        // PR alerts
                        ForEach(viewModel.newPRs, id: \.self) { exerciseName in
                            HStack(spacing: Theme.spacingSM) {
                                Image("icon_trophy")
                                    .resizable()
                                    .renderingMode(.original)
                                    .frame(width: 20, height: 20)
                                Text("New PR on \(exerciseName)!")
                                    .font(.system(size: Theme.captionSize, weight: .bold))
                                    .foregroundStyle(Color.appTextPrimary)
                            }
                            .padding(Theme.spacingMD)
                            .frame(maxWidth: .infinity)
                            .background(Color.appPRWeight.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSM))
                            .padding(.horizontal, Theme.spacingLG)
                            .transition(.scale.combined(with: .opacity))
                        }
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.newPRs)

                        // Exercise groups
                        ForEach(viewModel.exerciseGroups.indices, id: \.self) { groupIndex in
                            exerciseGroupCard(groupIndex: groupIndex)
                        }

                        // Add exercise
                        Button {
                            showExercisePicker = true
                        } label: {
                            HStack(spacing: Theme.spacingSM) {
                                Image("icon_plus_circle")
                                    .resizable()
                                    .renderingMode(.original)
                                    .frame(width: 24, height: 24)
                                Text("Add Exercise")
                            }
                            .font(.system(size: Theme.subheadlineSize, weight: .semibold))
                            .foregroundStyle(Color.appAccent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.spacingMD)
                            .background(Color.appCardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                        }
                        .padding(.horizontal, Theme.spacingLG)

                        Spacer(minLength: 100)
                    }
                    .padding(.top, Theme.spacingSM)
                }

                // Rest timer overlay
                if viewModel.showRestTimer {
                    RestTimerView(viewModel: viewModel)
                        .transition(.move(edge: .bottom))
                }
            }
            .screenBackground()
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
                        .foregroundStyle(Color.appWorkoutGreen)
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
                    showCompletion = true
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
            .fullScreenCover(isPresented: $showCompletion) {
                if let data = viewModel.completionData {
                    WorkoutCompletionView(data: data) {
                        viewModel.dismissCompletion()
                        showCompletion = false
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Exercise Group Card

    private func exerciseGroupCard(groupIndex: Int) -> some View {
        let group = viewModel.exerciseGroups[groupIndex]

        return VStack(alignment: .leading, spacing: Theme.spacingSM) {
            // Header
            HStack {
                Text(group.exerciseName)
                    .font(.system(size: Theme.subheadlineSize, weight: .bold))
                    .foregroundStyle(Color.appAccent)
                Spacer()
                Button {
                    viewModel.removeExercise(at: groupIndex)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.appTextTertiary)
                }
            }

            // Column headers
            HStack(spacing: 0) {
                Text("SET")
                    .frame(width: 36, alignment: .center)
                Text("PREVIOUS")
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("LBS")
                    .frame(width: 72, alignment: .center)
                Text("REPS")
                    .frame(width: 56, alignment: .center)
                Color.clear.frame(width: 40)
            }
            .font(.system(size: Theme.miniSize, weight: .bold))
            .foregroundStyle(Color.appTextTertiary)
            .padding(.top, Theme.spacingXS)

            // Sets
            ForEach(group.sets.indices, id: \.self) { setIndex in
                setRow(groupIndex: groupIndex, setIndex: setIndex)
            }

            // Add set
            Button {
                viewModel.addSet(to: groupIndex)
            } label: {
                HStack(spacing: Theme.spacingXS) {
                    Image(systemName: "plus")
                    Text("Add Set")
                }
                .font(.system(size: Theme.captionSize, weight: .medium))
                .foregroundStyle(Color.appAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.spacingSM)
            }
        }
        .cardStyle()
        .padding(.horizontal, Theme.spacingLG)
    }

    // MARK: - Set Row

    private func setRow(groupIndex: Int, setIndex: Int) -> some View {
        let set = viewModel.exerciseGroups[groupIndex].sets[setIndex]
        let isCompleted = set.isCompleted

        return VStack(spacing: 0) {
            HStack(spacing: 0) {
                // Set number
                Text(set.isWarmup ? "W" : "\(set.setNumber)")
                    .font(.system(size: Theme.captionSize, weight: .semibold))
                    .foregroundStyle(set.isWarmup ? Color.appAccent : Color.appTextPrimary)
                    .frame(width: 36, alignment: .center)

                // Previous
                Text("—")
                    .font(.system(size: Theme.captionSize))
                    .foregroundStyle(Color.appTextTertiary)
                    .frame(maxWidth: .infinity, alignment: .center)

                // Weight (lbs)
                TextField("0", value: $viewModel.exerciseGroups[groupIndex].sets[setIndex].weight, format: .number)
                    .keyboardType(.decimalPad)
                    .font(.system(size: Theme.captionSize, weight: .medium))
                    .multilineTextAlignment(.center)
                    .padding(.vertical, Theme.spacingXS)
                    .background(Color.appCardSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .frame(width: 72)

                // Reps
                TextField("0", value: $viewModel.exerciseGroups[groupIndex].sets[setIndex].reps, format: .number)
                    .keyboardType(.numberPad)
                    .font(.system(size: Theme.captionSize, weight: .medium))
                    .multilineTextAlignment(.center)
                    .padding(.vertical, Theme.spacingXS)
                    .background(Color.appCardSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .frame(width: 56)

                // Complete
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    viewModel.completeSet(groupIndex: groupIndex, setIndex: setIndex, context: modelContext)
                } label: {
                    Group {
                        if isCompleted {
                            Image("icon_checkmark_circle")
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: 24, height: 24)
                        } else {
                            Image(systemName: "circle")
                                .foregroundStyle(Color.appTextTertiary)
                                .font(.system(size: 22))
                        }
                    }
                    .scaleEffect(isCompleted ? 1.0 : 0.9)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isCompleted)
                }
                .frame(width: 40)
                .disabled(isCompleted)
            }
            .padding(.vertical, Theme.spacingXS)
            .background(isCompleted ? Color.appWorkoutGreen.opacity(0.06) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 4))

            // PR badge
            if set.isPersonalRecord {
                HStack(spacing: Theme.spacingXS) {
                    Spacer()
                    PRBadge(type: .oneRM)
                    Spacer()
                }
                .padding(.top, Theme.spacingXS)
            }
        }
    }
}
