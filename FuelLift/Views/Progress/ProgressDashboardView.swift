import SwiftUI
import SwiftData

struct ProgressDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ProgressViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    WeightChartView(data: viewModel.weightHistory)
                        .padding(.horizontal)

                    NutritionChartView(data: viewModel.calorieHistory)
                        .padding(.horizontal)

                    StrengthChartView(prs: viewModel.exercisePRs)
                        .padding(.horizontal)

                    NavigationLink {
                        BodyMeasurementsView()
                    } label: {
                        HStack {
                            Label("Body Measurements", systemImage: "ruler")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .cardStyle()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)

                    NavigationLink {
                        ProgressPhotosView()
                    } label: {
                        HStack {
                            Label("Progress Photos", systemImage: "photo.on.rectangle")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .cardStyle()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Progress")
            .onAppear {
                viewModel.loadData(context: modelContext)
            }
        }
    }
}
