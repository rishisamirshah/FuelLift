import SwiftUI
import Charts

struct CalorieSummaryCard: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                // Calorie ring
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 12)

                    Circle()
                        .trim(from: 0, to: viewModel.calorieProgress)
                        .stroke(
                            viewModel.calorieProgress >= 1.0 ? Color.red : Color.appCalories,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.spring, value: viewModel.calorieProgress)

                    VStack(spacing: 2) {
                        Text("\(viewModel.caloriesRemaining)")
                            .font(.title2.bold())
                        Text("remaining")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 120, height: 120)

                Spacer()

                // Macro bars
                VStack(alignment: .leading, spacing: 12) {
                    macroBar(
                        label: "Protein",
                        current: viewModel.proteinG,
                        goal: Double(viewModel.proteinGoal),
                        color: .appProtein
                    )
                    macroBar(
                        label: "Carbs",
                        current: viewModel.carbsG,
                        goal: Double(viewModel.carbsGoal),
                        color: .appCarbs
                    )
                    macroBar(
                        label: "Fat",
                        current: viewModel.fatG,
                        goal: Double(viewModel.fatGoal),
                        color: .appFat
                    )
                }
            }

            // Bottom stats
            HStack {
                statItem(label: "Eaten", value: "\(viewModel.caloriesEaten)")
                Divider().frame(height: 30)
                statItem(label: "Goal", value: "\(viewModel.calorieGoal)")
                Divider().frame(height: 30)
                statItem(label: "Remaining", value: "\(viewModel.caloriesRemaining)")
            }
        }
        .cardStyle()
    }

    private func macroBar(label: String, current: Double, goal: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(current.oneDecimal)/\(Int(goal))g")
                    .font(.caption2.bold())
            }
            ProgressView(value: min(current / max(goal, 1), 1.0))
                .tint(color)
        }
    }

    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline.bold())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
