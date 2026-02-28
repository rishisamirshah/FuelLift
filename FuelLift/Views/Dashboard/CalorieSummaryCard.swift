import SwiftUI

struct CalorieSummaryCard: View {
    @ObservedObject var viewModel: DashboardViewModel
    var showMacros: Bool = true

    var body: some View {
        VStack(spacing: Theme.spacingXL) {
            // Calorie ring + eaten/goal stats
            HStack(spacing: Theme.spacingXL) {
                // Large calorie ring
                CalorieRing(
                    caloriesEaten: viewModel.caloriesEaten,
                    calorieGoal: viewModel.calorieGoal,
                    size: Theme.calorieRingSize
                )

                Spacer()

                // Right side eaten/goal column
                VStack(alignment: .trailing, spacing: Theme.spacingMD) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(viewModel.caloriesEaten)")
                            .font(.system(size: Theme.headlineSize, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.appTextPrimary)
                            .contentTransition(.numericText())
                            .animation(.snappy, value: viewModel.caloriesEaten)
                        Text("eaten")
                            .font(.system(size: Theme.captionSize, weight: .medium))
                            .foregroundStyle(Color.appTextSecondary)
                    }

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(viewModel.calorieGoal)")
                            .font(.system(size: Theme.headlineSize, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.appTextTertiary)
                            .contentTransition(.numericText())
                        Text("goal")
                            .font(.system(size: Theme.captionSize, weight: .medium))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }

            // Macro rings row
            if showMacros {
            HStack(spacing: Theme.spacingXL) {
                MacroRing(
                    label: "Protein",
                    current: viewModel.proteinG,
                    goal: Double(viewModel.proteinGoal),
                    gradient: .proteinRingGradient,
                    emoji: "🥩",
                    size: Theme.macroRingSize
                )

                MacroRing(
                    label: "Carbs",
                    current: viewModel.carbsG,
                    goal: Double(viewModel.carbsGoal),
                    gradient: .carbsRingGradient,
                    emoji: "🍞",
                    size: Theme.macroRingSize
                )

                MacroRing(
                    label: "Fat",
                    current: viewModel.fatG,
                    goal: Double(viewModel.fatGoal),
                    gradient: .fatRingGradient,
                    emoji: "🧈",
                    size: Theme.macroRingSize
                )
            }
            .frame(maxWidth: .infinity)
            }
        }
        .cardStyle()
    }
}
