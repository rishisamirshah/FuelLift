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
                    // 1. Header with streak — unchanged
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

                    // 2. Scrollable week day selector
                    WeekDaySelector(selectedDate: $selectedDate)

                    // 3. Swipeable 3-page pager (Calories, Steps, Water)
                    DashboardPagerView(
                        viewModel: viewModel,
                        showMacros: profile?.showMacrosBreakdown ?? true
                    )
                    .padding(.horizontal, Theme.spacingLG)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.easeOut(duration: 0.4).delay(0.05), value: appeared)

                    // 4. Quick actions — unchanged
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

                    // 5. Today's workout
                    if profile?.showWorkoutSummary ?? true {
                        WorkoutSummaryCard(workout: viewModel.todayWorkout)
                            .padding(.horizontal, Theme.spacingLG)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                            .animation(.easeOut(duration: 0.4).delay(0.25), value: appeared)
                    }

                    // 6. Recently uploaded food list (always visible below all pages)
                    recentlyUploadedSection
                        .padding(.horizontal, Theme.spacingLG)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(.easeOut(duration: 0.4).delay(0.35), value: appeared)
                }
                .padding(.vertical, Theme.spacingLG)
            }
            .screenBackground()
            .navigationBarHidden(true)
            .onAppear {
                viewModel.loadDashboard(context: modelContext, for: selectedDate)
                workoutVM.badgeViewModel = badgeViewModel
                if let badgeVM = badgeViewModel {
                    badgeVM.recheckAllBadges(context: modelContext)
                    badgeVM.checkStreakBadges(currentStreak: viewModel.currentStreak, context: modelContext)
                }
                withAnimation(.easeOut(duration: 0.6)) {
                    appeared = true
                }
            }
            .onChange(of: selectedDate) { _, _ in
                viewModel.loadDashboard(context: modelContext, for: selectedDate)
            }
            .sheet(isPresented: $showCamera, onDismiss: {
                viewModel.loadDashboard(context: modelContext, for: selectedDate)
            }) {
                CameraScanView(nutritionViewModel: {
                    let vm = NutritionViewModel()
                    vm.badgeViewModel = badgeViewModel
                    return vm
                }())
            }
            .sheet(isPresented: $showNutritionPlan, onDismiss: {
                viewModel.loadDashboard(context: modelContext, for: selectedDate)
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
                    if entry.analysisStatus == "pending" || entry.analysisStatus == "analyzing" {
                        shimmerFoodCard(entry)
                    } else {
                        NavigationLink {
                            FoodEntryDetailView(entry: entry)
                        } label: {
                            foodEntryCard(entry)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteFoodEntry(entry)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Delete Food Entry

    private func deleteFoodEntry(_ entry: FoodEntry) {
        modelContext.delete(entry)
        try? modelContext.save()
        viewModel.loadDashboard(context: modelContext, for: selectedDate)
    }

    // MARK: - Shimmer Food Card (Pending Analysis)

    private func shimmerFoodCard(_ entry: FoodEntry) -> some View {
        HStack(spacing: Theme.spacingMD) {
            // Thumbnail
            if let imageData = entry.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                    .opacity(0.7)
            } else {
                RoundedRectangle(cornerRadius: Theme.cornerRadiusMD)
                    .fill(Color.appCardSecondary)
                    .frame(width: 100, height: 100)
                    .shimmer()
            }

            VStack(alignment: .leading, spacing: Theme.spacingSM) {
                // Name placeholder
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.appCardSecondary)
                    .frame(width: 140, height: 16)
                    .shimmer()

                // Calories placeholder
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.appCardSecondary)
                    .frame(width: 100, height: 20)
                    .shimmer()

                // Macro placeholder
                HStack(spacing: Theme.spacingLG) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appCardSecondary)
                        .frame(width: 40, height: 14)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appCardSecondary)
                        .frame(width: 40, height: 14)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appCardSecondary)
                        .frame(width: 40, height: 14)
                }
                .shimmer()
            }
        }
        .cardStyle()
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

// MARK: - Shimmer Modifier

private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.15),
                        Color.white.opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 300
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
