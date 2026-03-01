import SwiftUI

struct StepsBurnedPage: View {
    let steps: Int
    let activeCalories: Int

    private let stepsGoal = 10_000
    private let caloriesGoal = 500

    private var stepsProgress: Double {
        guard stepsGoal > 0 else { return 0 }
        return min(Double(steps) / Double(stepsGoal), 1.0)
    }

    private var caloriesProgress: Double {
        guard caloriesGoal > 0 else { return 0 }
        return min(Double(activeCalories) / Double(caloriesGoal), 1.0)
    }

    var body: some View {
        VStack(spacing: Theme.spacingXL) {
            HStack(spacing: Theme.spacingHuge) {
                // Steps ring
                VStack(spacing: Theme.spacingSM) {
                    ZStack {
                        ProgressRing(
                            progress: stepsProgress,
                            lineWidth: Theme.ringLineWidth,
                            gradient: LinearGradient(
                                colors: [Color.appAccent, Color.appAccentBright],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            size: 90
                        )

                        Image(systemName: "figure.walk")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(Color.appAccent)
                    }

                    VStack(spacing: 2) {
                        Text("\(steps.formattedWithComma)")
                            .font(.system(size: Theme.headlineSize, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.appTextPrimary)
                            .contentTransition(.numericText())

                        Text("/ \(stepsGoal.formattedWithComma) steps")
                            .font(.system(size: Theme.captionSize, weight: .medium))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }

                // Active calories ring
                VStack(spacing: Theme.spacingSM) {
                    ZStack {
                        ProgressRing(
                            progress: caloriesProgress,
                            lineWidth: Theme.ringLineWidth,
                            gradient: LinearGradient(
                                colors: [Color.appFatColor, Color.appFatColor.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            size: 90
                        )

                        Image(systemName: "flame.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(Color.appFatColor)
                    }

                    VStack(spacing: 2) {
                        Text("\(activeCalories)")
                            .font(.system(size: Theme.headlineSize, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.appTextPrimary)
                            .contentTransition(.numericText())

                        Text("/ \(caloriesGoal) kcal burned")
                            .font(.system(size: Theme.captionSize, weight: .medium))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }
        }
        .cardStyle()
    }
}

#Preview {
    StepsBurnedPage(steps: 6543, activeCalories: 320)
        .padding()
        .background(Color.appBackground)
}
