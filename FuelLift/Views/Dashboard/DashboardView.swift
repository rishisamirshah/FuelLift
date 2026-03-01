import SwiftUI
import SwiftData
import Combine

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
    @State private var capturedImage: UIImage?

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

                    // 6. Recently uploaded food list
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
            .onReceive(Timer.publish(every: 2, on: .main, in: .common).autoconnect()) { _ in
                // Auto-refresh while entries are pending analysis
                if viewModel.todayEntries.contains(where: { $0.analysisStatus == "pending" || $0.analysisStatus == "analyzing" }) {
                    viewModel.loadDashboard(context: modelContext, for: selectedDate)
                }
            }
            // CalAI-style camera scanner — opens directly
            .fullScreenCover(isPresented: $showCamera) {
                viewModel.loadDashboard(context: modelContext, for: selectedDate)
            } content: {
                FoodScannerView(
                    capturedImage: $capturedImage,
                    onBarcodeScan: { barcode in
                        // Create pending entry for barcode lookup
                        let entry = FoodEntry(
                            name: "Looking up...",
                            calories: 0, proteinG: 0, carbsG: 0, fatG: 0,
                            servingSize: "", mealType: "snack", source: "barcode"
                        )
                        entry.analysisStatus = "pending"
                        entry.barcode = barcode
                        modelContext.insert(entry)
                        try? modelContext.save()
                        viewModel.loadDashboard(context: modelContext, for: selectedDate)

                        let context = modelContext
                        Task.detached(priority: .userInitiated) {
                            do {
                                let nutrition = try await BarcodeService.shared.lookupBarcode(barcode)
                                await MainActor.run {
                                    entry.name = nutrition.name
                                    entry.calories = nutrition.calories
                                    entry.proteinG = nutrition.proteinG
                                    entry.carbsG = nutrition.carbsG
                                    entry.fatG = nutrition.fatG
                                    entry.servingSize = nutrition.servingSize
                                    entry.analysisStatus = "completed"
                                    try? context.save()
                                }
                            } catch {
                                await MainActor.run {
                                    entry.analysisStatus = "failed"
                                    entry.name = "Lookup failed"
                                    try? context.save()
                                }
                            }
                        }
                    }
                )
                .ignoresSafeArea()
            }
            .onChange(of: capturedImage) { _, newImage in
                guard let newImage else { return }
                // Downscale, create pending entry, analyze in background
                let scaled = Self.downscale(newImage, maxDimension: 1024)
                let entry = FoodEntry(
                    name: "Analyzing...",
                    calories: 0,
                    proteinG: 0,
                    carbsG: 0,
                    fatG: 0,
                    servingSize: "",
                    mealType: "snack",
                    source: "ai_scan"
                )
                entry.analysisStatus = "pending"
                if let imgData = newImage.jpegData(compressionQuality: 0.5) {
                    entry.imageData = imgData
                }
                modelContext.insert(entry)
                try? modelContext.save()
                viewModel.loadDashboard(context: modelContext, for: selectedDate)

                // Reset for next capture
                capturedImage = nil

                // Analyze in background
                let context = modelContext
                Task.detached(priority: .userInitiated) {
                    do {
                        let nutrition = try await GeminiService.shared.analyzeFoodPhoto(scaled)
                        await MainActor.run {
                            entry.name = nutrition.name
                            entry.calories = nutrition.calories
                            entry.proteinG = nutrition.proteinG
                            entry.carbsG = nutrition.carbsG
                            entry.fatG = nutrition.fatG
                            entry.servingSize = nutrition.servingSize
                            entry.analysisStatus = "completed"
                            if let ingredients = nutrition.ingredients,
                               let data = try? JSONEncoder().encode(ingredients) {
                                entry.ingredientsJSON = String(data: data, encoding: .utf8)
                            }
                            try? context.save()
                        }
                    } catch {
                        await MainActor.run {
                            entry.analysisStatus = "failed"
                            entry.name = "Analysis failed"
                            try? context.save()
                        }
                    }
                }
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
                        foodEntryRow(entry)
                    }
                }
            }
        }
    }

    // MARK: - Food Entry Row with Swipe Delete

    private func foodEntryRow(_ entry: FoodEntry) -> some View {
        ZStack(alignment: .trailing) {
            // Delete button behind
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    deleteFoodEntry(entry)
                }
            } label: {
                VStack {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                    Text("Delete")
                        .font(.system(size: Theme.miniSize, weight: .medium))
                        .foregroundStyle(.white)
                }
                .frame(width: 80)
                .frame(maxHeight: .infinity)
                .background(Color.appFatColor)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
            }

            NavigationLink {
                FoodEntryDetailView(entry: entry)
            } label: {
                foodEntryCard(entry)
            }
            .buttonStyle(.plain)
            .offset(x: swipeOffsets[entry.id] ?? 0)
            .gesture(
                DragGesture(minimumDistance: 30, coordinateSpace: .local)
                    .onChanged { value in
                        // Only respond to horizontal swipes
                        let horizontal = abs(value.translation.width)
                        let vertical = abs(value.translation.height)
                        guard horizontal > vertical else { return }

                        if value.translation.width < 0 {
                            swipeOffsets[entry.id] = max(value.translation.width, -90)
                        } else {
                            swipeOffsets[entry.id] = 0
                        }
                    }
                    .onEnded { value in
                        let horizontal = abs(value.translation.width)
                        let vertical = abs(value.translation.height)

                        if horizontal > vertical && value.translation.width < -60 {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                swipeOffsets[entry.id] = -90
                            }
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                swipeOffsets[entry.id] = 0
                            }
                        }
                    }
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
    }

    @State private var swipeOffsets: [String: CGFloat] = [:]

    // MARK: - Delete Food Entry

    private func deleteFoodEntry(_ entry: FoodEntry) {
        swipeOffsets.removeValue(forKey: entry.id)
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

    /// Downscale image to reduce upload size and avoid Gemini timeouts
    private static func downscale(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        guard max(size.width, size.height) > maxDimension else { return image }
        let scale = maxDimension / max(size.width, size.height)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
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
