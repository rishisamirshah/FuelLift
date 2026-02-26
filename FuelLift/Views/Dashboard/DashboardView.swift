import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showCamera = false
    @State private var showActiveWorkout = false
    @StateObject private var workoutVM = WorkoutViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Streak
                    if viewModel.currentStreak > 0 {
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(.orange)
                            Text("\(viewModel.currentStreak) day streak!")
                                .font(.subheadline.bold())
                            Spacer()
                        }
                        .padding(.horizontal)
                    }

                    // Calorie ring
                    CalorieSummaryCard(viewModel: viewModel)
                        .padding(.horizontal)

                    // Quick actions
                    HStack(spacing: 12) {
                        quickAction(icon: "camera.fill", label: "Scan Food") {
                            showCamera = true
                        }
                        quickAction(icon: "dumbbell.fill", label: "Start Workout") {
                            workoutVM.startWorkout()
                            showActiveWorkout = true
                        }
                    }
                    .padding(.horizontal)

                    // Water
                    waterCard
                        .padding(.horizontal)

                    // Today's workout
                    WorkoutSummaryCard(workout: viewModel.todayWorkout)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("FuelLift")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .onAppear {
                viewModel.loadDashboard(context: modelContext)
            }
            .sheet(isPresented: $showCamera) {
                CameraScanView(nutritionViewModel: NutritionViewModel())
            }
            .fullScreenCover(isPresented: $showActiveWorkout) {
                ActiveWorkoutView(viewModel: workoutVM)
            }
        }
    }

    private func quickAction(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(label)
                    .font(.caption.bold())
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private var waterCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundStyle(.appWater)
                Text("Water")
                    .font(.subheadline.bold())
                Spacer()
                Text("\(viewModel.waterML) / \(viewModel.waterGoal) mL")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: Double(viewModel.waterML), total: Double(viewModel.waterGoal))
                .tint(.appWater)

            HStack {
                ForEach([250, 500, 750], id: \.self) { amount in
                    Button("+\(amount)") {
                        let entry = WaterEntry(amountML: amount)
                        modelContext.insert(entry)
                        try? modelContext.save()
                        viewModel.loadDashboard(context: modelContext)
                    }
                    .buttonStyle(.bordered)
                    .tint(.cyan)
                    .controlSize(.mini)
                }
            }
        }
        .cardStyle()
    }
}
