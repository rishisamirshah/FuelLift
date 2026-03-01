import SwiftUI
import SwiftData

struct WeightEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \BodyMetric.date, order: .reverse) private var metrics: [BodyMetric]
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }

    @State private var weightLbs: Double = 187.0
    @State private var isSaving = false
    @State private var goalWeightLbs: Double = 170.0
    @State private var showGoalSection = false
    @State private var showPlanPrompt = false

    private var latestWeight: Double? {
        metrics.first(where: { $0.weightKG != nil })?.weightKG.map { $0 * 2.20462 }
    }

    var body: some View {
        VStack(spacing: Theme.spacingHuge) {
            Spacer()

            // Title
            Text("Log Weight")
                .font(.system(size: Theme.headlineSize, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)

            // Large weight display
            VStack(spacing: Theme.spacingSM) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(String(format: "%.1f", weightLbs))
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)
                        .contentTransition(.numericText())

                    Text("lbs")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color.appTextSecondary)
                }

                if let latest = latestWeight {
                    let diff = weightLbs - latest
                    Text(String(format: "%+.1f lbs from last", diff))
                        .font(.system(size: Theme.captionSize))
                        .foregroundStyle(Color.appTextTertiary)
                }
            }

            // Stepper controls
            HStack(spacing: Theme.spacingXXL) {
                // -1 lb
                stepperButton(systemName: "minus", large: true) {
                    withAnimation(.snappy(duration: 0.15)) {
                        weightLbs = max(50, weightLbs - 1.0)
                    }
                }

                // -0.1 lb
                stepperButton(systemName: "minus", large: false) {
                    withAnimation(.snappy(duration: 0.15)) {
                        weightLbs = max(50, weightLbs - 0.1)
                    }
                }

                // +0.1 lb
                stepperButton(systemName: "plus", large: false) {
                    withAnimation(.snappy(duration: 0.15)) {
                        weightLbs = min(500, weightLbs + 0.1)
                    }
                }

                // +1 lb
                stepperButton(systemName: "plus", large: true) {
                    withAnimation(.snappy(duration: 0.15)) {
                        weightLbs = min(500, weightLbs + 1.0)
                    }
                }
            }

            Spacer()

            // Goal weight section
            VStack(spacing: Theme.spacingMD) {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showGoalSection.toggle()
                    }
                } label: {
                    HStack {
                        Image("icon_target")
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 20, height: 20)
                        Text("Set Weight Goal")
                            .font(.system(size: Theme.bodySize, weight: .semibold))
                            .foregroundStyle(Color.appTextPrimary)
                        Spacer()
                        Image(systemName: showGoalSection ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.appTextTertiary)
                    }
                    .padding(Theme.spacingLG)
                    .background(Color.appCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, Theme.spacingXXL)

                if showGoalSection {
                    VStack(spacing: Theme.spacingLG) {
                        // Goal weight display
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(String(format: "%.1f", goalWeightLbs))
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.appAccent)
                                .contentTransition(.numericText())
                            Text("lbs")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color.appTextSecondary)
                        }

                        // Goal stepper controls
                        HStack(spacing: Theme.spacingXXL) {
                            stepperButton(systemName: "minus", large: true) {
                                withAnimation(.snappy(duration: 0.15)) {
                                    goalWeightLbs = max(50, goalWeightLbs - 1.0)
                                }
                            }
                            stepperButton(systemName: "minus", large: false) {
                                withAnimation(.snappy(duration: 0.15)) {
                                    goalWeightLbs = max(50, goalWeightLbs - 0.1)
                                }
                            }
                            stepperButton(systemName: "plus", large: false) {
                                withAnimation(.snappy(duration: 0.15)) {
                                    goalWeightLbs = min(500, goalWeightLbs + 0.1)
                                }
                            }
                            stepperButton(systemName: "plus", large: true) {
                                withAnimation(.snappy(duration: 0.15)) {
                                    goalWeightLbs = min(500, goalWeightLbs + 1.0)
                                }
                            }
                        }

                        // Set Goal button
                        Button {
                            saveGoalWeight()
                        } label: {
                            Text("Set Goal")
                                .font(.system(size: Theme.bodySize, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Theme.spacingMD)
                                .background(Color.appAccent.opacity(0.85))
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSM))
                        }
                    }
                    .padding(Theme.spacingLG)
                    .background(Color.appCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                    .padding(.horizontal, Theme.spacingXXL)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }

            // Save button
            Button {
                saveWeight()
            } label: {
                Text("Save")
                    .font(.system(size: Theme.subheadlineSize, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.spacingLG)
                    .background(Color.appAccent)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
            }
            .disabled(isSaving)
            .padding(.horizontal, Theme.spacingXXL)
            .padding(.bottom, Theme.spacingXL)
        }
        .screenBackground()
        .navigationTitle("Log Weight")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Create a Plan?", isPresented: $showPlanPrompt) {
            NavigationLink("Yes") {
                WorkoutPlannerView()
            }
            Button("Not Now", role: .cancel) {}
        } message: {
            Text("You've set a weight goal. Would you like to create an AI workout plan to help you reach it?")
        }
        .onAppear {
            if let latest = latestWeight {
                weightLbs = latest
            }
            if let goalKG = profile?.weightGoalKG {
                goalWeightLbs = goalKG * 2.20462
            }
        }
    }

    private func stepperButton(systemName: String, large: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: large ? 18 : 14, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)
                .frame(width: large ? 56 : 44, height: large ? 56 : 44)
                .background(Color.appCardBackground)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private func saveWeight() {
        isSaving = true
        let weightKG = weightLbs / 2.20462
        let metric = BodyMetric()
        metric.weightKG = weightKG
        modelContext.insert(metric)
        try? modelContext.save()
        dismiss()
    }

    private func saveGoalWeight() {
        profile?.weightGoalKG = goalWeightLbs / 2.20462
        try? modelContext.save()
        showPlanPrompt = true
    }
}

#Preview {
    NavigationStack {
        WeightEditorView()
    }
}
