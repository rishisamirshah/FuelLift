import SwiftUI
import SwiftData

struct WorkoutPlannerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = WorkoutPlannerViewModel()
    @State private var step = 0

    var userHeight: Double?
    var userWeight: Double?
    var userAge: Int?

    private let totalSteps = 4

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress indicator
                HStack(spacing: Theme.spacingSM) {
                    ForEach(0..<totalSteps, id: \.self) { i in
                        Capsule()
                            .fill(i <= step ? Color.appAccent : Color.appCardSecondary)
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, Theme.spacingXXL)
                .padding(.top, Theme.spacingLG)

                if viewModel.generatedPlan != nil && !viewModel.planSaved {
                    planPreviewContent
                } else if viewModel.planSaved {
                    planSavedContent
                } else {
                    TabView(selection: $step) {
                        goalStep.tag(0)
                        experienceStep.tag(1)
                        scheduleStep.tag(2)
                        equipmentStep.tag(3)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    // Navigation buttons
                    navigationButtons
                        .padding(.horizontal, Theme.spacingXXL)
                        .padding(.bottom, Theme.spacingXXL)
                }
            }
            .screenBackground()
            .navigationTitle("AI Workout Planner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
    }

    // MARK: - Step 1: Goal

    private var goalStep: some View {
        VStack(spacing: Theme.spacingXL) {
            Text("What's Your Goal?")
                .font(.system(size: Theme.headlineSize, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)

            Text("This helps us tailor the perfect plan for you.")
                .font(.system(size: Theme.bodySize))
                .foregroundStyle(Color.appTextSecondary)

            VStack(spacing: Theme.spacingMD) {
                ForEach(viewModel.goals, id: \.self) { goal in
                    Button {
                        viewModel.selectedGoal = goal
                    } label: {
                        HStack(spacing: Theme.spacingMD) {
                            iconView(goalIcon(goal), size: 24)
                                .foregroundStyle(viewModel.selectedGoal == goal ? Color.appAccent : Color.appTextSecondary)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                                Text(goal)
                                    .font(.system(size: Theme.subheadlineSize, weight: .semibold))
                                    .foregroundStyle(Color.appTextPrimary)
                                Text(goalSubtitle(goal))
                                    .font(.system(size: Theme.captionSize))
                                    .foregroundStyle(Color.appTextSecondary)
                            }

                            Spacer()

                            if viewModel.selectedGoal == goal {
                                Image("icon_checkmark_circle")
                                    .resizable()
                                    .renderingMode(.original)
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .padding(Theme.spacingLG)
                        .background(viewModel.selectedGoal == goal ? Color.appAccent.opacity(0.1) : Color.appCardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.cornerRadiusMD)
                                .stroke(viewModel.selectedGoal == goal ? Color.appAccent : Color.clear, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()
        }
        .padding(.horizontal, Theme.spacingXXL)
        .padding(.top, Theme.spacingLG)
    }

    // MARK: - Step 2: Experience

    private var experienceStep: some View {
        VStack(spacing: Theme.spacingXL) {
            Text("Experience Level")
                .font(.system(size: Theme.headlineSize, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)

            Text("Be honest so we can match the intensity.")
                .font(.system(size: Theme.bodySize))
                .foregroundStyle(Color.appTextSecondary)

            VStack(spacing: Theme.spacingMD) {
                ForEach(viewModel.experienceLevels, id: \.self) { level in
                    Button {
                        viewModel.selectedExperience = level
                    } label: {
                        HStack(spacing: Theme.spacingMD) {
                            Image(systemName: experienceIcon(level))
                                .font(.title2)
                                .foregroundStyle(viewModel.selectedExperience == level ? Color.appAccent : Color.appTextSecondary)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                                Text(level)
                                    .font(.system(size: Theme.subheadlineSize, weight: .semibold))
                                    .foregroundStyle(Color.appTextPrimary)
                                Text(experienceSubtitle(level))
                                    .font(.system(size: Theme.captionSize))
                                    .foregroundStyle(Color.appTextSecondary)
                            }

                            Spacer()

                            if viewModel.selectedExperience == level {
                                Image("icon_checkmark_circle")
                                    .resizable()
                                    .renderingMode(.original)
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .padding(Theme.spacingLG)
                        .background(viewModel.selectedExperience == level ? Color.appAccent.opacity(0.1) : Color.appCardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.cornerRadiusMD)
                                .stroke(viewModel.selectedExperience == level ? Color.appAccent : Color.clear, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()
        }
        .padding(.horizontal, Theme.spacingXXL)
        .padding(.top, Theme.spacingLG)
    }

    // MARK: - Step 3: Schedule

    private var scheduleStep: some View {
        VStack(spacing: Theme.spacingXL) {
            Text("Your Schedule")
                .font(.system(size: Theme.headlineSize, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)

            Text("How often and how long can you train?")
                .font(.system(size: Theme.bodySize))
                .foregroundStyle(Color.appTextSecondary)

            VStack(spacing: Theme.spacingXL) {
                // Days per week
                VStack(spacing: Theme.spacingMD) {
                    Text("Days Per Week")
                        .font(.system(size: Theme.captionSize, weight: .semibold))
                        .foregroundStyle(Color.appTextSecondary)

                    HStack(spacing: Theme.spacingMD) {
                        Button {
                            if viewModel.daysPerWeek > 2 {
                                viewModel.daysPerWeek -= 1
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(viewModel.daysPerWeek > 2 ? Color.appAccent : Color.appTextTertiary)
                        }
                        .disabled(viewModel.daysPerWeek <= 2)

                        Text("\(viewModel.daysPerWeek)")
                            .font(.system(size: Theme.titleSize, weight: .bold))
                            .foregroundStyle(Color.appAccent)
                            .frame(width: 60)

                        Button {
                            if viewModel.daysPerWeek < 7 {
                                viewModel.daysPerWeek += 1
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(viewModel.daysPerWeek < 7 ? Color.appAccent : Color.appTextTertiary)
                        }
                        .disabled(viewModel.daysPerWeek >= 7)
                    }

                    Text("days")
                        .font(.system(size: Theme.captionSize))
                        .foregroundStyle(Color.appTextTertiary)
                }
                .cardStyle()

                // Session length
                VStack(spacing: Theme.spacingMD) {
                    Text("Session Length")
                        .font(.system(size: Theme.captionSize, weight: .semibold))
                        .foregroundStyle(Color.appTextSecondary)

                    HStack(spacing: Theme.spacingSM) {
                        ForEach(viewModel.sessionLengths, id: \.self) { length in
                            Button {
                                viewModel.sessionLength = length
                            } label: {
                                Text(length)
                                    .font(.system(size: Theme.captionSize, weight: .semibold))
                                    .foregroundStyle(viewModel.sessionLength == length ? .white : Color.appTextSecondary)
                                    .padding(.horizontal, Theme.spacingMD)
                                    .padding(.vertical, Theme.spacingSM)
                                    .background(viewModel.sessionLength == length ? Color.appAccent : Color.appCardSecondary)
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSM))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .cardStyle()
            }

            Spacer()
        }
        .padding(.horizontal, Theme.spacingXXL)
        .padding(.top, Theme.spacingLG)
    }

    // MARK: - Step 4: Equipment

    private var equipmentStep: some View {
        VStack(spacing: Theme.spacingXL) {
            Text("Available Equipment")
                .font(.system(size: Theme.headlineSize, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)

            Text("Select everything you have access to.")
                .font(.system(size: Theme.bodySize))
                .foregroundStyle(Color.appTextSecondary)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: Theme.spacingMD),
                GridItem(.flexible(), spacing: Theme.spacingMD)
            ], spacing: Theme.spacingMD) {
                ForEach(viewModel.equipmentOptions, id: \.self) { equipment in
                    Button {
                        if viewModel.selectedEquipment.contains(equipment) {
                            viewModel.selectedEquipment.remove(equipment)
                        } else {
                            viewModel.selectedEquipment.insert(equipment)
                        }
                    } label: {
                        HStack(spacing: Theme.spacingSM) {
                            iconView(equipmentIcon(equipment), size: 20)
                                .foregroundStyle(viewModel.selectedEquipment.contains(equipment) ? Color.appAccent : Color.appTextSecondary)

                            Text(equipment)
                                .font(.system(size: Theme.captionSize, weight: .semibold))
                                .foregroundStyle(viewModel.selectedEquipment.contains(equipment) ? Color.appTextPrimary : Color.appTextSecondary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(Theme.spacingMD)
                        .background(viewModel.selectedEquipment.contains(equipment) ? Color.appAccent.opacity(0.1) : Color.appCardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.cornerRadiusMD)
                                .stroke(viewModel.selectedEquipment.contains(equipment) ? Color.appAccent : Color.clear, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: Theme.captionSize))
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(.horizontal, Theme.spacingXXL)
        .padding(.top, Theme.spacingLG)
    }

    // MARK: - Plan Preview

    private var planPreviewContent: some View {
        ScrollView {
            VStack(spacing: Theme.spacingXL) {
                Text("Your AI Workout Plan")
                    .font(.system(size: Theme.headlineSize, weight: .bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(.top, Theme.spacingLG)

                Text("\(viewModel.generatedPlan?.routines.count ?? 0) day split tailored to your goals")
                    .font(.system(size: Theme.bodySize))
                    .foregroundStyle(Color.appTextSecondary)

                if let plan = viewModel.generatedPlan {
                    ForEach(Array(plan.routines.enumerated()), id: \.offset) { index, routine in
                        routineCard(routine, dayNumber: index + 1)
                    }
                }

                // Refinement input
                Divider()
                    .padding(.vertical, Theme.spacingXS)

                VStack(spacing: Theme.spacingSM) {
                    HStack(spacing: Theme.spacingSM) {
                        TextField("Refine your plan...", text: $viewModel.refinementInput)
                            .font(.system(size: Theme.bodySize))
                            .foregroundStyle(Color.appTextPrimary)
                            .padding(Theme.spacingMD)
                            .background(Color.appCardSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSM))

                        Button {
                            Task { await viewModel.refinePlan() }
                        } label: {
                            if viewModel.isRefining {
                                ProgressView()
                                    .tint(Color.appAccent)
                                    .frame(width: 36, height: 36)
                            } else {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: Theme.bodySize))
                                    .foregroundStyle(.white)
                                    .frame(width: 36, height: 36)
                                    .background(Color.appAccent)
                                    .clipShape(Circle())
                            }
                        }
                        .disabled(viewModel.refinementInput.isEmpty || viewModel.isRefining)
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.system(size: Theme.captionSize))
                            .foregroundStyle(.red)
                    }
                }

                // Save Plan button
                Button {
                    viewModel.savePlan(context: modelContext)
                } label: {
                    HStack(spacing: Theme.spacingSM) {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save Plan as Templates")
                    }
                    .font(.system(size: Theme.subheadlineSize, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.spacingMD)
                    .background(Color.appAccent)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                }

                // Regenerate button
                Button {
                    viewModel.generatedPlan = nil
                    step = 0
                } label: {
                    Text("Start Over")
                        .font(.system(size: Theme.bodySize, weight: .semibold))
                        .foregroundStyle(Color.appTextSecondary)
                }

                Spacer(minLength: Theme.spacingHuge)
            }
            .padding(.horizontal, Theme.spacingXXL)
        }
    }

    // MARK: - Plan Saved

    private var planSavedContent: some View {
        VStack(spacing: Theme.spacingXL) {
            Spacer()

            Image("icon_checkmark_circle")
                .resizable()
                .renderingMode(.original)
                .frame(width: 64, height: 64)

            Text("Plan Saved!")
                .font(.system(size: Theme.headlineSize, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)

            Text("Your new routines are ready in Templates. Start your first workout now!")
                .font(.system(size: Theme.bodySize))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)

            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.system(size: Theme.subheadlineSize, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.spacingMD)
                    .background(Color.appAccent)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
            }

            Spacer()
        }
        .padding(.horizontal, Theme.spacingXXL)
    }

    // MARK: - Routine Card

    private func routineCard(_ routine: ClaudeService.GeneratedRoutine, dayNumber: Int) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            HStack {
                Text("Day \(dayNumber)")
                    .font(.system(size: Theme.captionSize, weight: .bold))
                    .foregroundStyle(Color.appAccent)
                    .padding(.horizontal, Theme.spacingSM)
                    .padding(.vertical, Theme.spacingXS)
                    .background(Color.appAccent.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSM))

                Text(routine.name)
                    .font(.system(size: Theme.subheadlineSize, weight: .bold))
                    .foregroundStyle(Color.appTextPrimary)
            }

            ForEach(routine.exercises, id: \.self) { exercise in
                HStack(spacing: Theme.spacingSM) {
                    Circle()
                        .fill(Color.appWorkoutGreen)
                        .frame(width: 6, height: 6)
                    Text(exercise)
                        .font(.system(size: Theme.bodySize))
                        .foregroundStyle(Color.appTextPrimary)
                    Spacer()
                    Text("\(routine.setsPerExercise) sets")
                        .font(.system(size: Theme.captionSize))
                        .foregroundStyle(Color.appTextTertiary)
                }
            }

            if !routine.notes.isEmpty {
                Text(routine.notes)
                    .font(.system(size: Theme.captionSize))
                    .foregroundStyle(Color.appTextSecondary)
                    .italic()
            }
        }
        .cardStyle()
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: Theme.spacingLG) {
            if step > 0 {
                Button {
                    withAnimation { step -= 1 }
                } label: {
                    Text("Back")
                        .font(.headline)
                        .foregroundStyle(Color.appTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(Theme.spacingMD)
                        .background(Color.appCardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                }
            }

            if step < totalSteps - 1 {
                Button {
                    withAnimation { step += 1 }
                } label: {
                    Text("Next")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(Theme.spacingMD)
                        .background(canAdvance ? Color.appAccent : Color.appTextTertiary)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                }
                .disabled(!canAdvance)
            } else {
                Button {
                    Task {
                        await viewModel.generatePlan(
                            userStats: (height: userHeight, weight: userWeight, age: userAge)
                        )
                    }
                } label: {
                    if viewModel.isGenerating {
                        HStack(spacing: Theme.spacingSM) {
                            ProgressView()
                                .tint(.white)
                            Text("Generating...")
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(Theme.spacingMD)
                    } else {
                        HStack(spacing: Theme.spacingSM) {
                            Image("icon_wand_stars")
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: 24, height: 24)
                            Text("Generate Plan")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(Theme.spacingMD)
                    }
                }
                .background(viewModel.canGenerate ? Color.appAccent : Color.appTextTertiary)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                .disabled(!viewModel.canGenerate || viewModel.isGenerating)
            }
        }
    }

    // MARK: - Helpers

    private var canAdvance: Bool {
        switch step {
        case 0: return !viewModel.selectedGoal.isEmpty
        case 1: return !viewModel.selectedExperience.isEmpty
        case 2: return true
        case 3: return !viewModel.selectedEquipment.isEmpty
        default: return true
        }
    }

    private func goalIcon(_ goal: String) -> String {
        switch goal {
        case "Build Muscle": return "figure.strengthtraining.traditional"
        case "Lose Fat": return "icon_fire_streak"
        case "Get Stronger": return "icon_bolt"
        case "General Fitness": return "heart.fill"
        default: return "star.fill"
        }
    }

    private func goalSubtitle(_ goal: String) -> String {
        switch goal {
        case "Build Muscle": return "Hypertrophy-focused training"
        case "Lose Fat": return "High-intensity fat burning"
        case "Get Stronger": return "Strength and power building"
        case "General Fitness": return "Balanced health and wellness"
        default: return ""
        }
    }

    private func experienceIcon(_ level: String) -> String {
        switch level {
        case "Beginner": return "figure.walk"
        case "Intermediate": return "figure.run"
        case "Advanced": return "figure.highintensity.intervaltraining"
        default: return "figure.walk"
        }
    }

    private func experienceSubtitle(_ level: String) -> String {
        switch level {
        case "Beginner": return "New to lifting or less than 6 months"
        case "Intermediate": return "6 months to 2 years of training"
        case "Advanced": return "2+ years of consistent training"
        default: return ""
        }
    }

    private func equipmentIcon(_ equipment: String) -> String {
        switch equipment {
        case "Barbell": return "figure.strengthtraining.traditional"
        case "Dumbbells": return "icon_dumbbell"
        case "Machines": return "gearshape.fill"
        case "Cables": return "arrow.up.and.down.text.horizontal"
        case "Bodyweight": return "figure.core.training"
        case "Kettlebell": return "figure.strengthtraining.functional"
        case "Resistance Bands": return "arrow.left.and.right"
        default: return "circle.fill"
        }
    }

    /// Returns a pixel art Image for asset names (prefixed with "icon_"), or an SF Symbol Image otherwise.
    @ViewBuilder
    private func iconView(_ name: String, size: CGFloat) -> some View {
        if name.hasPrefix("icon_") {
            Image(name)
                .resizable()
                .renderingMode(.original)
                .frame(width: size, height: size)
        } else {
            Image(systemName: name)
                .font(.system(size: size))
        }
    }
}
