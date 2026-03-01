import SwiftUI
import SwiftData

struct GoalSetupView: View {
    enum Mode {
        case onboarding
        case editing
    }

    var mode: Mode = .onboarding

    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]
    @State private var step = 0

    // Body info
    @State private var gender = "Male"
    @State private var age = ""
    @State private var heightCM = ""
    @State private var weightKG = ""
    @State private var activityLevel = "Moderate"

    // Goals
    @State private var goal = "Lose Fat"
    @State private var calorieGoal = "\(AppConstants.defaultCalorieGoal)"
    @State private var proteinGoal = "\(AppConstants.defaultProteinGoal)"

    @State private var isSaving = false
    @State private var isCalculatingAI = false
    @State private var aiReasoning: String?

    private let genders = ["Male", "Female", "Other"]
    private let activityLevels = ["Sedentary", "Light", "Moderate", "Active", "Very Active"]
    private let goals = ["Lose Fat", "Maintain", "Build Muscle"]

    var body: some View {
        VStack(spacing: Theme.spacingXXL) {
            // Progress indicator
            HStack(spacing: Theme.spacingSM) {
                ForEach(0..<3) { i in
                    Capsule()
                        .fill(i <= step ? Color.appAccent : Color.appCardSecondary)
                        .frame(height: 4)
                }
            }
            .padding(.horizontal, Theme.spacingXXL)
            .padding(.top, Theme.spacingLG)

            TabView(selection: $step) {
                bodyInfoStep.tag(0)
                goalStep.tag(1)
                macroStep.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Navigation buttons
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

                if step < 2 {
                    Button {
                        withAnimation { step += 1 }
                    } label: {
                        Text("Next")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(Theme.spacingMD)
                            .background(Color.appAccent)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                    }
                } else {
                    Button {
                        Task { await saveProfile() }
                    } label: {
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding(Theme.spacingMD)
                        } else {
                            Text(mode == .editing ? "Save Goals" : "Finish Setup")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(Theme.spacingMD)
                        }
                    }
                    .background(Color.appAccent)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                    .disabled(isSaving)
                }
            }
            .padding(.horizontal, Theme.spacingXXL)
            .padding(.bottom, Theme.spacingXXL)
        }
        .screenBackground()
        .navigationTitle(mode == .editing ? "Edit Goals" : "Setup")
        .navigationBarBackButtonHidden(mode == .onboarding)
        .onAppear {
            if mode == .editing, let profile = profiles.first {
                gender = profile.gender ?? "Male"
                age = profile.age.map(String.init) ?? ""
                heightCM = profile.heightCM.map { String(Int($0)) } ?? ""
                weightKG = profile.weightKG.map { String(Int($0)) } ?? ""
                activityLevel = profile.activityLevel ?? "Moderate"
                goal = profile.goal ?? "Maintain"
                calorieGoal = String(profile.calorieGoal)
                proteinGoal = String(profile.proteinGoal)
            }
        }
    }

    // MARK: - Steps

    private var bodyInfoStep: some View {
        VStack(spacing: Theme.spacingXL) {
            Text("About You")
                .font(.system(size: Theme.headlineSize, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)

            VStack(spacing: Theme.spacingLG) {
                Picker("Gender", selection: $gender) {
                    ForEach(genders, id: \.self) { Text($0) }
                }
                .pickerStyle(.segmented)

                HStack(spacing: Theme.spacingLG) {
                    ThemedField(label: "Age", text: $age, placeholder: "25", keyboard: .numberPad)
                    ThemedField(label: "Height (cm)", text: $heightCM, placeholder: "175", keyboard: .decimalPad)
                }

                ThemedField(label: "Weight (kg)", text: $weightKG, placeholder: "75", keyboard: .decimalPad)

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
            }
            .cardStyle()

            Spacer()
        }
        .padding(.horizontal, Theme.spacingXXL)
    }

    private var goalStep: some View {
        VStack(spacing: Theme.spacingXL) {
            Text("What's Your Goal?")
                .font(.system(size: Theme.headlineSize, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)

            VStack(spacing: Theme.spacingMD) {
                ForEach(goals, id: \.self) { g in
                    Button {
                        goal = g
                        recalculateCalories()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                                Text(g)
                                    .font(.headline)
                                    .foregroundStyle(Color.appTextPrimary)
                                Text(goalDescription(g))
                                    .font(.system(size: Theme.captionSize))
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                            Spacer()
                            if goal == g {
                                Image("icon_checkmark_circle")
                                    .pixelArt()
                                    .frame(width: 28, height: 28)
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

            Spacer()
        }
        .padding(.horizontal, Theme.spacingXXL)
    }

    private var macroStep: some View {
        VStack(spacing: Theme.spacingXL) {
            Text("Daily Targets")
                .font(.system(size: Theme.headlineSize, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)

            Text("We've calculated targets based on your info. Adjust if needed.")
                .font(.system(size: Theme.bodySize))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)

            VStack(spacing: Theme.spacingLG) {
                ThemedField(label: "Calories (kcal)", text: $calorieGoal, placeholder: "2000", keyboard: .numberPad)
                ThemedField(label: "Protein (g)", text: $proteinGoal, placeholder: "150", keyboard: .numberPad)
            }
            .cardStyle()

            // AI Calculate button
            Button {
                Task { await calculateWithAI() }
            } label: {
                HStack(spacing: Theme.spacingSM) {
                    if isCalculatingAI {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image("icon_wand_stars")
                            .pixelArt()
                            .frame(width: 24, height: 24)
                    }
                    Text("AI Calculate")
                        .font(.system(size: Theme.bodySize, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.spacingMD)
                .background(Color.appAccent)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
            }
            .disabled(isCalculatingAI)

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
            }

            Text("Carbs and fat will auto-fill based on remaining calories.")
                .font(.system(size: Theme.captionSize))
                .foregroundStyle(Color.appTextTertiary)

            Spacer()
        }
        .padding(.horizontal, Theme.spacingXXL)
    }

    // MARK: - Logic

    private func goalDescription(_ g: String) -> String {
        switch g {
        case "Lose Fat": return "Calorie deficit to shed body fat"
        case "Maintain": return "Keep your current weight stable"
        case "Build Muscle": return "Calorie surplus for muscle growth"
        default: return ""
        }
    }

    private func calculateWithAI() async {
        isCalculatingAI = true
        do {
            let result = try await ClaudeService.shared.calculateNutritionGoals(
                gender: gender,
                age: Int(age) ?? 25,
                heightCM: Double(heightCM) ?? 175,
                weightKG: Double(weightKG) ?? 75,
                activityLevel: activityLevel,
                goal: goal
            )
            calorieGoal = String(result.calories)
            proteinGoal = String(result.proteinG)
            aiReasoning = result.reasoning
        } catch {
            aiReasoning = "Error: \(error.localizedDescription)"
        }
        isCalculatingAI = false
    }

    private func recalculateCalories() {
        let weight = Double(weightKG) ?? 75
        let base = weight * 24 // rough BMR
        let multiplier: Double = switch activityLevel {
        case "Sedentary": 1.2
        case "Light": 1.375
        case "Moderate": 1.55
        case "Active": 1.725
        case "Very Active": 1.9
        default: 1.55
        }
        var tdee = base * multiplier
        switch goal {
        case "Lose Fat": tdee -= 500
        case "Build Muscle": tdee += 300
        default: break
        }
        calorieGoal = String(Int(tdee))
        proteinGoal = String(Int(weight * 2.0))
    }

    private func saveProfile() async {
        isSaving = true
        let cal = Int(calorieGoal) ?? AppConstants.defaultCalorieGoal
        let protein = Int(proteinGoal) ?? AppConstants.defaultProteinGoal
        let fat = cal / 4 / 9  // ~25% of cals from fat
        let carbs = (cal - protein * 4 - fat * 9) / 4

        if mode == .editing, let existingProfile = profiles.first {
            existingProfile.calorieGoal = cal
            existingProfile.proteinGoal = protein
            existingProfile.carbsGoal = carbs
            existingProfile.fatGoal = fat
            existingProfile.gender = gender
            existingProfile.age = Int(age)
            existingProfile.heightCM = Double(heightCM)
            existingProfile.weightKG = Double(weightKG)
            existingProfile.activityLevel = activityLevel
            existingProfile.goal = goal
            existingProfile.updatedAt = Date()
            try? modelContext.save()
            isSaving = false
            dismiss()
            return
        }

        let profileData: [String: Any] = [
            "displayName": AuthService.shared.currentUser?.displayName ?? "",
            "email": AuthService.shared.currentUser?.email ?? "",
            "gender": gender,
            "age": Int(age) ?? 0,
            "heightCM": Double(heightCM) ?? 0,
            "weightKG": Double(weightKG) ?? 0,
            "activityLevel": activityLevel,
            "goal": goal,
            "calorieGoal": cal,
            "proteinGoal": protein,
            "carbsGoal": carbs,
            "fatGoal": fat,
            "waterGoalML": AppConstants.defaultWaterGoalML,
            "hasCompletedOnboarding": true,
            "useMetricUnits": true,
            "notificationsEnabled": true,
            "currentStreak": 0,
            "longestStreak": 0
        ]

        do {
            try await FirestoreService.shared.createUserProfile(profileData)
            let uid = AuthService.shared.currentUser?.uid ?? UUID().uuidString
            let localProfile = UserProfile(id: uid)
            localProfile.calorieGoal = cal
            localProfile.proteinGoal = protein
            localProfile.carbsGoal = carbs
            localProfile.fatGoal = fat
            localProfile.hasCompletedOnboarding = true
            localProfile.gender = gender
            localProfile.age = Int(age)
            localProfile.heightCM = Double(heightCM)
            localProfile.weightKG = Double(weightKG)
            localProfile.activityLevel = activityLevel
            localProfile.goal = goal
            modelContext.insert(localProfile)
            try modelContext.save()

            authViewModel.needsOnboarding = false
        } catch {
            print("Failed to save profile: \(error)")
        }
        isSaving = false
    }
}

// MARK: - Themed Field

struct ThemedField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            Text(label)
                .font(.system(size: Theme.captionSize, weight: .semibold))
                .foregroundStyle(Color.appTextSecondary)
            TextField(placeholder, text: $text)
                .keyboardType(keyboard)
                .padding(Theme.spacingMD)
                .background(Color.appCardSecondary)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSM))
                .foregroundStyle(Color.appTextPrimary)
        }
    }
}

// Keep the old name as a typealias for compatibility
typealias LabeledField = ThemedField
