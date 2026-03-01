import SwiftUI

struct DashboardPagerView: View {
    @ObservedObject var viewModel: DashboardViewModel
    var showMacros: Bool = true
    @State private var currentPage = 0

    var body: some View {
        TabView(selection: $currentPage) {
            // Page 1: Calories + Macros
            CalorieSummaryCard(viewModel: viewModel, showMacros: showMacros)
                .tag(0)

            // Page 2: Steps + Calories Burned
            StepsBurnedPage(
                steps: viewModel.stepsToday,
                activeCalories: viewModel.activeCaloriesBurned
            )
            .tag(1)

            // Page 3: Water Tracker
            WaterPage(viewModel: viewModel)
                .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .frame(height: 260)
    }
}
