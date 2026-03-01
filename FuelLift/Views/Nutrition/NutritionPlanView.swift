import SwiftUI
import SwiftData

struct NutritionPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]

    // Body info
    @State private var gender = "Male"
    @State private var age = ""
    @State private var heightFeet = ""
    @State private var heightInches = ""
    @State private var weightLbs = ""

    // Goal
    @State private var goal = "Maintain"
    @State private var targetWeightLbs = ""

    // Activity
    @State private var activityLevel = "Moderate"
    @State private var workoutsPerWeek = 3

    // Dietary preference
    @State private var dietaryPreference = "Standard"

    // Macro targets
    @State private var calorieGoal = ""
    @State private var proteinGoal = ""
    @State private var carbsGoal = ""
    @State private var fatGoal = ""

    // AI state
    @State private var isCalculating = false
    @State private var aiReasoning: String?
    @State private var isSaving = false

    private let genders = ["Male", "Female", "Other"]
    private let goals = ["Lose Fat", "Maintain", "Build Muscle"]
    private let activityLevels = ["Sedentary", "Light", "Moderate", "Active", "Very Active"]
    private let dietaryPreferences = ["Standard", "High Protein", "Low Carb", "Keto", "Vegetarian", "Vegan"]

    private var profile: UserProfile? { profiles.first }

    private var showTargetWeight: Bool {
        goal == "Lose Fat" || goal == "Build Muscle"
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: Theme.spacingXXL) {
                        aboutYouSection
                        goalSection
                        if showTargetWeight {
                            targetWeightSection
                        }
                        activitySection
                        dietaryPreferenceSection
                        aiCalculateSection
                        dailyTargetsSection
                        resetSection

                        // Bottom padding for save button
                        Color.clear.frame(height: 70)
                    }
                    .padding(.vertical, Theme.spacingLG)
                }
                .screenBackground()

                saveButton
            }
            .navigationTitle("Nutrition Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .onAppear { prefillFromProfile() }
        }
    }

    // MARK: - About You

    private var aboutYouSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            Text("About You")
                .sectionHeaderStyle()
                .padding(.horizontal, Theme.spacingLG)

            VStack(spacing: Theme.spacingLG) {
                Picker("Gender", selection: $gender) {
                    ForEach(genders, id: \.self) { Text($0) }
                }
                .pickerStyle(.segmented)

                ThemedField(label: "Age", text: $age, placeholder: "25", keyboard: .numberPad)

                HStack(spacing: Theme.spacingLG) {
                    ThemedField(label: "Height (ft)", text: $heightFeet, placeholder: "5", keyboard: .numberPad)
                    ThemedField(label: "Height (in)", text: $heightInches, placeholder: "9", keyboard: .numberPad)
                }

                ThemedField(label: "Weight (lbs)", text: $weightLbs, placeholder: "165", keyboard: .decimalPad)
            }
            .cardStyle()
            .padding(.horizontal, Theme.spacingLG)
        }
    }

    // MARK: - Goal

    private var goalSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            Text("Your Goal")
                .sectionHeaderStyle()
                .padding(.horizontal, Theme.spacingLG)

            VStack(spacing: Theme.spacingMD) {
                ForEach(goals, id: \.self) { g in
                    Button {
                        withAnimation { goal = g }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                                Text(g)
                                    .font(.system(size: Theme.bodySize, weight: .semibold))
                                    .foregroundStyle(Color.appTextPrimary)
                                Text(goalDescription(g))
                                    .font(.system(size: Theme.captionSize))
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                            Spacer()
                            if goal == g {
                                Image("icon_checkmark_circle").pixelArt()
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .padding(Theme.spacingLG)
                        .background(goal == g ? Color.appAccent.opacity(0.1) : Color.appCardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.cornerRadiusMD)
                                .stroke(goal == g ? Color.appAccent : Color.clear, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Theme.spacingLG)
        }
    }

    // MARK: - Target Weight

    private var targetWeightSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            Text("Target Weight")
                .sectionHeaderStyle()
                .padding(.horizontal, Theme.spacingLG)

            ThemedField(label: "Target Weight (lbs)", text: $targetWeightLbs, placeholder: "155", keyboard: .decimalPad)
                .cardStyle()
                .padding(.horizontal, Theme.spacingLG)
        }
    }

    // MARK: - Activity

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            Text("Activity & Lifestyle")
                .sectionHeaderStyle()
                .padding(.horizontal, Theme.spacingLG)

            VStack(spacing: Theme.spacingLG) {
                VStack(alignment: .leading, spacing: Theme.spacingSM) {
                    Text("Activity Level")
                        .font(.system(size: Theme.captionSize, weight: .semibold))
                        .foregroundStyle(Color.appTextSecondary)
                    Picker("Activity", selection: $activityLevel) {
                        ForEach(activityLevels, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.menu)
                    .tint(Color.appAccent)
                }

                HStack {
                    Text("Workouts per week")
                        .font(.system(size: Theme.bodySize, weight: .medium))
                        .foregroundStyle(Color.appTextPrimary)
                    Spacer()
                    Stepper("\(workoutsPerWeek)", value: $workoutsPerWeek, in: 1...7)
                        .font(.system(size: Theme.bodySize, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.appAccent)
                }
            }
            .cardStyle()
            .padding(.horizontal, Theme.spacingLG)
        }
    }

    // MARK: - Dietary Preference

    private var dietaryPreferenceSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            Text("Dietary Preference")
                .sectionHeaderStyle()
                .padding(.horizontal, Theme.spacingLG)

            FlowLayout(spacing: Theme.spacingSM) {
                ForEach(dietaryPreferences, id: \.self) { pref in
                    Button {
                        dietaryPreference = pref
                    } label: {
                        Text(pref)
                            .font(.system(size: Theme.captionSize, weight: .semibold))
                            .foregroundStyle(dietaryPreference == pref ? .white : Color.appTextPrimary)
                            .padding(.horizontal, Theme.spacingLG)
                            .padding(.vertical, Theme.spacingSM)
                            .background(dietaryPreference == pref ? Color.appAccent : Color.appCardBackground)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(dietaryPreference == pref ? Color.clear : Color.appTextTertiary.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Theme.spacingLG)
        }
    }

    // MARK: - AI Calculate

    private var aiCalculateSection: some View {
        VStack(spacing: Theme.spacingMD) {
            Button {
                Task { await calculateWithAI() }
            } label: {
                HStack(spacing: Theme.spacingSM) {
                    if isCalculating {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image("icon_wand_stars").pixelArt().frame(width: 24, height: 24)
                    }
                    Text("Generate My Plan")
                        .font(.system(size: Theme.bodySize, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.spacingLG)
                .background(
                    LinearGradient(colors: [Color.appAccent, Color.appAccent.opacity(0.8)],
                                   startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
            }
            .disabled(isCalculating)
            .padding(.horizontal, Theme.spacingLG)

            if let reasoning = aiReasoning {
                DisclosureGroup("AI Reasoning") {
                    Text(reasoning)
                        .font(.system(size: Theme.captionSize))
                        .foregroundStyle(Color.appTextSecondary)
                }
                .font(.system(size: Theme.captionSize, weight: .semibold))
                .foregroundStyle(Color.appTextSecondary)
                .padding(Theme.spacingMD)
                .background(Color.appCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSM))
                .padding(.horizontal, Theme.spacingLG)
            }
        }
    }

    // MARK: - Daily Targets

    private var dailyTargetsSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            Text("Your Daily Targets")
                .sectionHeaderStyle()
                .padding(.horizontal, Theme.spacingLG)

            VStack(spacing: Theme.spacingLG) {
                ThemedField(label: "Calories (kcal)", text: $calorieGoal, placeholder: "2000", keyboard: .numberPad)
                ThemedField(label: "Protein (g)", text: $proteinGoal, placeholder: "150", keyboard: .numberPad)
                ThemedField(label: "Carbs (g)", text: $carbsGoal, placeholder: "250", keyboard: .numberPad)
                ThemedField(label: "Fat (g)", text: $fatGoal, placeholder: "65", keyboard: .numberPad)
            }
            .cardStyle()
            .padding(.horizontal, Theme.spacingLG)
        }
    }

    // MARK: - Reset

    private var resetSection: some View {
        Button {
            calorieGoal = String(AppConstants.defaultCalorieGoal)
            proteinGoal = String(AppConstants.defaultProteinGoal)
            carbsGoal = String(AppConstants.defaultCarbsGoal)
            fatGoal = String(AppConstants.defaultFatGoal)
            aiReasoning = nil
        } label: {
            Text("Reset AI Plan")
                .font(.system(size: Theme.bodySize, weight: .medium))
                .foregroundStyle(Color.appFatColor)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            Task { await saveGoals() }
        } label: {
            if isSaving {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.spacingLG)
            } else {
                Text("Save Goals")
                    .font(.system(size: Theme.bodySize, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.spacingLG)
            }
        }
        .background(Color.appAccent)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
        .padding(.horizontal, Theme.spacingLG)
        .padding(.bottom, Theme.spacingLG)
        .disabled(isSaving)
    }

    // MARK: - Logic

    private func prefillFromProfile() {
        guard let profile else { return }
        gender = profile.gender ?? "Male"
        age = profile.age.map(String.init) ?? ""
        if let cm = profile.heightCM {
            let totalInches = cm / 2.54
            heightFeet = String(Int(totalInches) / 12)
            heightInches = String(Int(totalInches) % 12)
        }
        if let kg = profile.weightKG {
            weightLbs = String(Int(kg * 2.20462))
        }
        activityLevel = profile.activityLevel ?? "Moderate"
        goal = profile.goal ?? "Maintain"
        dietaryPreference = profile.dietaryPreference ?? "Standard"
        workoutsPerWeek = profile.workoutsPerWeek ?? 3
        if let targetKG = profile.targetWeightKG {
            targetWeightLbs = String(Int(targetKG * 2.20462))
        }
        calorieGoal = String(profile.calorieGoal)
        proteinGoal = String(profile.proteinGoal)
        carbsGoal = String(profile.carbsGoal)
        fatGoal = String(profile.fatGoal)
    }

    private func goalDescription(_ g: String) -> String {
        switch g {
        case "Lose Fat": return "Calorie deficit to shed body fat"
        case "Maintain": return "Keep your current weight stable"
        case "Build Muscle": return "Calorie surplus for muscle growth"
        default: return ""
        }
    }

    private var heightInCM: Double {
        let feet = Double(heightFeet) ?? 5
        let inches = Double(heightInches) ?? 9
        return (feet * 12 + inches) * 2.54
    }

    private var weightInKG: Double {
        (Double(weightLbs) ?? 165) / 2.20462
    }

    private var targetWeightInKG: Double? {
        guard let lbs = Double(targetWeightLbs), !targetWeightLbs.isEmpty else { return nil }
        return lbs / 2.20462
    }

    private func calculateWithAI() async {
        isCalculating = true
        do {
            let result = try await ClaudeService.shared.calculateNutritionGoals(
                gender: gender,
                age: Int(age) ?? 25,
                heightCM: heightInCM,
                weightKG: weightInKG,
                activityLevel: activityLevel,
                goal: goal,
                dietaryPreference: dietaryPreference,
                targetWeightKG: targetWeightInKG,
                workoutsPerWeek: workoutsPerWeek
            )
            calorieGoal = String(result.calories)
            proteinGoal = String(result.proteinG)
            carbsGoal = String(result.carbsG)
            fatGoal = String(result.fatG)
            aiReasoning = result.reasoning
        } catch {
            aiReasoning = "Error: \(error.localizedDescription)"
        }
        isCalculating = false
    }

    private func saveGoals() async {
        isSaving = true
        guard let profile else {
            isSaving = false
            return
        }

        profile.calorieGoal = Int(calorieGoal) ?? AppConstants.defaultCalorieGoal
        profile.proteinGoal = Int(proteinGoal) ?? AppConstants.defaultProteinGoal
        profile.carbsGoal = Int(carbsGoal) ?? AppConstants.defaultCarbsGoal
        profile.fatGoal = Int(fatGoal) ?? AppConstants.defaultFatGoal
        profile.gender = gender
        profile.age = Int(age)
        profile.heightCM = heightInCM
        profile.weightKG = weightInKG
        profile.activityLevel = activityLevel
        profile.goal = goal
        profile.dietaryPreference = dietaryPreference
        profile.workoutsPerWeek = workoutsPerWeek
        profile.targetWeightKG = targetWeightInKG
        profile.updatedAt = Date()

        try? modelContext.save()
        isSaving = false
        dismiss()
    }
}

// MARK: - Flow Layout for Dietary Preference Pills

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                                  proposal: ProposedViewSize(result.sizes[index]))
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], sizes: [CGSize], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var sizes: [CGSize] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            sizes.append(size)
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (positions, sizes, CGSize(width: maxWidth, height: y + rowHeight))
    }
}
