import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(BadgeViewModel.self) private var badgeViewModel: BadgeViewModel?
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
            ScrollView {
                VStack(spacing: Theme.spacingXXL) {
                    // Header with streak
                    HStack {
                        Image("logo_fuellift")
                            .pixelArt()
                            .frame(height: 32)
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
                                quickAction(iconName: "icon_camera", label: "Scan Food") {
                                    showCamera = true
                                }
                                quickAction(iconName: "icon_dumbbell", label: "Start Workout") {
                                    workoutVM.startWorkout()
                                    showActiveWorkout = true
                                }
                            }
                            quickAction(iconName: "icon_wand_stars", label: "AI Nutrition Plan") {
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
            .navigationBarHidden(true)
            .onAppear {
                viewModel.loadDashboard(context: modelContext)
                // Wire badge VM to workout VM
                workoutVM.badgeViewModel = badgeViewModel
                // Check streak badges after dashboard recalculates streak
                if let badgeVM = badgeViewModel {
                    badgeVM.recheckAllBadges(context: modelContext)
                    badgeVM.checkStreakBadges(currentStreak: viewModel.currentStreak, context: modelContext)
                }
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
                CameraScanView(nutritionViewModel: {
                    let vm = NutritionViewModel()
                    vm.badgeViewModel = badgeViewModel
                    return vm
                }())
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

    private func quickAction(iconName: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Theme.spacingMD) {
                Image(iconName)
                    .pixelArt()
                    .frame(width: 28, height: 28)
                Text(label)
                    .font(.system(size: Theme.bodySize, weight: .bold))
                    .foregroundStyle(Color.appTextPrimary)
            }
            .pixelButtonStyle()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Water Card

    private var waterCard: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            HStack {
                Image("icon_water_drop")
                    .pixelArt()
                    .frame(width: 24, height: 24)
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
                            .background(Color.appCardSecondary)
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
                    Image("icon_fork_knife")
                        .pixelArt()
                        .frame(width: 40, height: 40)

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
                    Image("icon_fire_streak")
                        .pixelArt()
                        .frame(width: 20, height: 20)
                    Text("\(entry.calories) calories")
                        .font(.system(size: Theme.subheadlineSize, weight: .bold))
                        .foregroundStyle(Color.appTextPrimary)
                }

                // Macro pills
                HStack(spacing: Theme.spacingLG) {
                    macroLabel(iconName: "icon_fork_knife", value: "\(Int(entry.proteinG))g")
                    macroLabel(iconName: "icon_leaf", value: "\(Int(entry.carbsG))g")
                    macroLabel(iconName: "icon_water_drop", value: "\(Int(entry.fatG))g")
                }
            }
        }
        .cardStyle()
    }

    private func macroLabel(iconName: String, value: String) -> some View {
        HStack(spacing: Theme.spacingXS) {
            Image(iconName)
                .pixelArt()
                .frame(width: 18, height: 18)
            Text(value)
                .font(.system(size: Theme.captionSize, weight: .medium))
                .foregroundStyle(Color.appTextPrimary)
        }
    }
}
