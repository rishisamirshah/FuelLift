import SwiftUI

struct WaterPage: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Environment(\.modelContext) private var modelContext

    private var waterProgress: Double {
        guard viewModel.waterGoal > 0 else { return 0 }
        return min(Double(viewModel.waterML) / Double(viewModel.waterGoal), 1.0)
    }

    var body: some View {
        VStack(spacing: Theme.spacingXL) {
            HStack(spacing: Theme.spacingXL) {
                // Water ring
                ZStack {
                    ProgressRing(
                        progress: waterProgress,
                        lineWidth: Theme.ringLineWidth,
                        gradient: LinearGradient(
                            colors: [Color.appWaterColor, Color.appWaterColor.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        size: 100
                    )

                    VStack(spacing: 2) {
                        Text("\(viewModel.waterML)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.appTextPrimary)
                            .contentTransition(.numericText())
                            .animation(.snappy, value: viewModel.waterML)

                        Text("mL")
                            .font(.system(size: Theme.captionSize, weight: .medium))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }

                // Right side: goal + buttons
                VStack(alignment: .leading, spacing: Theme.spacingMD) {
                    HStack(spacing: Theme.spacingSM) {
                        Image("icon_water_drop")
                            .pixelArt()
                            .frame(width: 20, height: 20)
                        Text("Water")
                            .font(.system(size: Theme.subheadlineSize, weight: .bold))
                            .foregroundStyle(Color.appTextPrimary)
                    }

                    Text("\(viewModel.waterML) / \(viewModel.waterGoal) mL")
                        .font(.system(size: Theme.captionSize, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.appTextSecondary)

                    HStack(spacing: Theme.spacingSM) {
                        ForEach([250, 500, 750], id: \.self) { amount in
                            Button {
                                let entry = WaterEntry(amountML: amount)
                                modelContext.insert(entry)
                                try? modelContext.save()
                                viewModel.loadDashboard(context: modelContext)
                            } label: {
                                Text("+\(amount)")
                                    .font(.system(size: Theme.captionSize, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color.appWaterColor)
                                    .padding(.horizontal, Theme.spacingMD)
                                    .padding(.vertical, Theme.spacingXS)
                                    .background(Color.appCardSecondary)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .cardStyle()
    }
}

#Preview {
    WaterPage(viewModel: DashboardViewModel())
        .padding()
        .background(Color.appBackground)
}
