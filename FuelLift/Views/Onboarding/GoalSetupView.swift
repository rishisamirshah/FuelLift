import SwiftUI
import SwiftData

struct GoalSetupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.modelContext) private var modelContext
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

    private let genders = ["Male", "Female", "Other"]
    private let activityLevels = ["Sedentary", "Light", "Moderate", "Active", "Very Active"]
    private let goals = ["Lose Fat", "Maintain", "Build Muscle"]

    var body: some View {
        VStack(spacing: 24) {
            ProgressView(value: Double(step + 1), total: 3)
                .tint(.orange)
                .padding(.horizontal)

            TabView(selection: $step) {
                // Step 1: Body Info
                bodyInfoStep.tag(0)
                // Step 2: Goal
                goalStep.tag(1)
                // Step 3: Macros
                macroStep.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Navigation buttons
            HStack(spacing: 16) {
                if step > 0 {
                    Button("Back") {
                        withAnimation { step -= 1 }
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()

                if step < 2 {
                    Button("Next") {
                        withAnimation { step += 1 }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                } else {
                    Button {
                        Task { await saveProfile() }
                    } label: {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Finish Setup")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .disabled(isSaving)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .navigationTitle("Setup")
        .navigationBarBackButtonHidden()
    }

    // MARK: - Steps

    private var bodyInfoStep: some View {
        VStack(spacing: 20) {
            Text("About You")
                .font(.title2.bold())

            Picker("Gender", selection: $gender) {
                ForEach(genders, id: \.self) { Text($0) }
            }
            .pickerStyle(.segmented)

            HStack(spacing: 16) {
                LabeledField(label: "Age", text: $age, placeholder: "25", keyboard: .numberPad)
                LabeledField(label: "Height (cm)", text: $heightCM, placeholder: "175", keyboard: .decimalPad)
            }

            LabeledField(label: "Weight (kg)", text: $weightKG, placeholder: "75", keyboard: .decimalPad)

            VStack(alignment: .leading, spacing: 8) {
                Text("Activity Level")
                    .font(.subheadline.bold())
                Picker("Activity", selection: $activityLevel) {
                    ForEach(activityLevels, id: \.self) { Text($0) }
                }
                .pickerStyle(.menu)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var goalStep: some View {
        VStack(spacing: 20) {
            Text("What's Your Goal?")
                .font(.title2.bold())

            ForEach(goals, id: \.self) { g in
                Button {
                    goal = g
                    recalculateCalories()
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(g)
                                .font(.headline)
                            Text(goalDescription(g))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if goal == g {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding()
                    .background(goal == g ? Color.orange.opacity(0.1) : Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var macroStep: some View {
        VStack(spacing: 20) {
            Text("Daily Targets")
                .font(.title2.bold())

            Text("We've calculated targets based on your info. Adjust if needed.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            LabeledField(label: "Calories (kcal)", text: $calorieGoal, placeholder: "2000", keyboard: .numberPad)
            LabeledField(label: "Protein (g)", text: $proteinGoal, placeholder: "150", keyboard: .numberPad)

            Text("Carbs and fat will auto-fill based on remaining calories.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(.horizontal, 24)
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
            // Also save locally
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
            modelContext.insert(localProfile)
            try modelContext.save()

            authViewModel.needsOnboarding = false
        } catch {
            print("Failed to save profile: \(error)")
        }
        isSaving = false
    }
}

// MARK: - Reusable Field

struct LabeledField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline.bold())
            TextField(placeholder, text: $text)
                .keyboardType(keyboard)
                .textFieldStyle(.roundedBorder)
        }
    }
}
