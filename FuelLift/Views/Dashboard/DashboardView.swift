import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = DashboardViewModel()
    @Query private var profiles: [UserProfile]
    @State private var showCamera = false
    @State private var showActiveWorkout = false
    @State private var showNutritionPlan = false
    @State private var selectedDate = Date()
    @StateObject private var workoutVM = WorkoutViewModel()
    @State private var appeared = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: Theme.spacingXXL) {
                        // Header with streak
                        HStack {
                            Text("FuelLift")
                                .font(.system(size: Theme.titleSize, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.appTextPrimary)
                            Spacer()
                            if profile?.showStreakBadge ?? true, viewModel.currentStreak > 0 {
                                StreakBadge(count: viewModel.currentStreak, style: .compact)
                            }
                        }
                        .padding(.horizontal, Theme.spacingLG)

                        // Week day selector
                        WeekDaySelector(selectedDate: $selectedDate)
                            .padding(.horizontal, Theme.spacingSM)

                        // Calorie ring card
                        CalorieSummaryCard(viewModel: viewModel, showMacros: profile?.showMacrosBreakdown ?? true)
                            .padding(.horizontal, Theme.spacingLG)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                            .animation(.easeOut(duration: 0.4).delay(0.05), value: appeared)

                        // Quick actions
                        if profile?.showQuickActions ?? true {
                            VStack(spacing: Theme.spacingMD) {
                                HStack(spacing: Theme.spacingMD) {
                                    quickAction(icon: "camera.fill", label: "Scan Food") {
                                        showCamera = true
                                    }
                                    quickAction(icon: "dumbbell.fill", label: "Start Workout") {
                                        workoutVM.startWorkout()
                                        showActiveWorkout = true
                                    }
                                }
                                quickAction(icon: "wand.and.stars", label: "AI Nutrition Plan") {
                                    showNutritionPlan = true
                                }
                            }
                            .padding(.horizontal, Theme.spacingLG)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                            .animation(.easeOut(duration: 0.4).delay(0.15), value: appeared)
                        }

                        // Water tracker
                        if profile?.showWaterTracker ?? true {
                            waterCard
                                .padding(.horizontal, Theme.spacingLG)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 20)
                                .animation(.easeOut(duration: 0.4).delay(0.25), value: appeared)
                        }

                        // Today's workout
                        if profile?.showWorkoutSummary ?? true {
                            WorkoutSummaryCard(workout: viewModel.todayWorkout)
                                .padding(.horizontal, Theme.spacingLG)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 20)
                                .animation(.easeOut(duration: 0.4).delay(0.35), value: appeared)
                        }

                        // Recently uploaded section
                        recentlyUploadedSection
                            .padding(.horizontal, Theme.spacingLG)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                            .animation(.easeOut(duration: 0.4).delay(0.45), value: appeared)
                    }
                    .padding(.vertical, Theme.spacingLG)
                }
                .screenBackground()

                // Floating action button
                FloatingActionButton {
                    showCamera = true
                }
                .padding(Theme.spacingXL)
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.loadDashboard(context: modelContext)
                withAnimation(.easeOut(duration: 0.6)) {
                    appeared = true
                }
            }
            .onChange(of: selectedDate) { _, _ in
                viewModel.loadDashboard(context: modelContext)
            }
            .sheet(isPresented: $showCamera, onDismiss: {
                viewModel.loadDashboard(context: modelContext)
            }) {
                CameraScanView(nutritionViewModel: NutritionViewModel())
            }
            .sheet(isPresented: $showNutritionPlan, onDismiss: {
                viewModel.loadDashboard(context: modelContext)
            }) {
                NutritionPlanView()
            }
            .fullScreenCover(isPresented: $showActiveWorkout) {
                ActiveWorkoutView(viewModel: workoutVM)
            }
        }
    }

    // MARK: - Quick Action Button

    private func quickAction(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Theme.spacingSM) {
                Image(systemName: icon)
                    .font(.system(size: Theme.inlineIconSize, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
                Text(label)
                    .font(.system(size: Theme.bodySize, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(Theme.spacingLG)
            .background(Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Water Card

    private var waterCard: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundStyle(Color.appWaterColor)
                Text("Water")
                    .font(.system(size: Theme.subheadlineSize, weight: .bold))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Text("\(viewModel.waterML) / \(viewModel.waterGoal) mL")
                    .font(.system(size: Theme.captionSize, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.appTextSecondary)
            }

            // Water progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: Theme.cornerRadiusSM)
                        .fill(Color.appCardSecondary)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: Theme.cornerRadiusSM)
                        .fill(Color.appWaterColor)
                        .frame(width: geo.size.width * min(Double(viewModel.waterML) / max(Double(viewModel.waterGoal), 1), 1.0), height: 8)
                        .animation(.spring(response: 0.6), value: viewModel.waterML)
                }
            }
            .frame(height: 8)

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
                            .background(Color.appWaterColor.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Recently Uploaded

    private var recentlyUploadedSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            Text("Recently uploaded")
                .sectionHeaderStyle()

            if viewModel.todayEntries.isEmpty {
                VStack(spacing: Theme.spacingMD) {
                    Image(systemName: "fork.knife.circle")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.appTextTertiary)

                    Text("Tap + to add your first meal of the day")
                        .font(.system(size: Theme.bodySize))
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.spacingHuge)
                .background(Color.appCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
            } else {
                ForEach(viewModel.todayEntries, id: \.id) { entry in
                    NavigationLink {
                        FoodEntryDetailView(entry: entry)
                    } label: {
                        foodEntryCard(entry)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Food Entry Card

    private func foodEntryCard(_ entry: FoodEntry) -> some View {
        HStack(spacing: Theme.spacingMD) {
            // Thumbnail
            if let imageData = entry.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
            }

            VStack(alignment: .leading, spacing: Theme.spacingSM) {
                // Name + time
                HStack {
                    Text(entry.name)
                        .lineLimit(1)
                        .font(.system(size: Theme.bodySize, weight: .medium))
                        .foregroundStyle(Color.appTextPrimary)
                    Spacer()
                    Text(entry.date.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: Theme.captionSize))
                        .foregroundStyle(Color.appTextSecondary)
                }

                // Calories
                HStack(spacing: Theme.spacingXS) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.appCaloriesColor)
                    Text("\(entry.calories) calories")
                        .font(.system(size: Theme.subheadlineSize, weight: .bold))
                        .foregroundStyle(Color.appTextPrimary)
                }

                // Macro pills
                HStack(spacing: Theme.spacingLG) {
                    macroLabel(icon: "fork.knife", value: "\(Int(entry.proteinG))g", color: Color.appProteinColor)
                    macroLabel(icon: "leaf.fill", value: "\(Int(entry.carbsG))g", color: Color.appCarbsColor)
                    macroLabel(icon: "drop.fill", value: "\(Int(entry.fatG))g", color: Color.appFatColor)
                }
            }
        }
        .padding(Theme.spacingLG)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
    }

    private func macroLabel(icon: String, value: String, color: Color) -> some View {
        HStack(spacing: Theme.spacingXS) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: Theme.captionSize, weight: .medium))
                .foregroundStyle(Color.appTextPrimary)
        }
    }
}
