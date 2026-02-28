import SwiftUI
import SwiftData

struct ProgressDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ProgressViewModel()
    @Query private var profiles: [UserProfile]
    @State private var appeared = false

    private var profile: UserProfile? { profiles.first }
    private var streakCount: Int { profile?.currentStreak ?? 0 }
    private var currentWeightLbs: Double {
        if let latest = viewModel.weightHistory.last {
            return latest.weight * 2.20462
        }
        return (profile?.weightKG ?? 0) * 2.20462
    }
    private var startWeightLbs: Double {
        if let first = viewModel.weightHistory.first {
            return first.weight * 2.20462
        }
        return currentWeightLbs
    }
    private var goalWeightLbs: Double { (profile?.weightGoalKG ?? 85.0) * 2.20462 }

    private var goalPercent: Int {
        guard startWeightLbs != goalWeightLbs else { return 100 }
        let total = abs(startWeightLbs - goalWeightLbs)
        let progress = abs(startWeightLbs - currentWeightLbs)
        return min(100, Int((progress / total) * 100))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacingXXL) {
                    // MARK: - Streak + Badges
                    HStack(spacing: Theme.spacingLG) {
                        StreakBadge(count: streakCount, style: .expanded)

                        NavigationLink {
                            MilestonesView()
                        } label: {
                            VStack(spacing: Theme.spacingSM) {
                                Image(systemName: "medal.fill")
                                    .font(.system(size: 44))
                                    .foregroundStyle(Color.appTextSecondary)

                                Text("\(earnedBadgeCount)")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.appTextPrimary)

                                Text("Badges Earned")
                                    .font(.system(size: Theme.captionSize, weight: .medium))
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.spacingLG)
                            .background(Color.appCardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, Theme.spacingLG)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.easeOut(duration: 0.4).delay(0.05), value: appeared)

                    // MARK: - Current Weight
                    HStack {
                        VStack(alignment: .leading, spacing: Theme.spacingXS) {
                            Text("Current Weight")
                                .font(.system(size: Theme.captionSize, weight: .medium))
                                .foregroundStyle(Color.appTextSecondary)

                            Text("\(Int(currentWeightLbs)) lbs")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.appTextPrimary)
                        }
                        Spacer()
                        NavigationLink {
                            WeightEditorView()
                        } label: {
                            HStack(spacing: 4) {
                                Text("Log weight")
                                    .font(.system(size: Theme.captionSize, weight: .semibold))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 11, weight: .bold))
                            }
                            .foregroundStyle(Color.appTextPrimary)
                            .padding(.horizontal, Theme.spacingMD)
                            .padding(.vertical, Theme.spacingSM)
                            .background(Color.appCardSecondary)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    .cardStyle()
                    .padding(.horizontal, Theme.spacingLG)

                    // Start / Goal
                    HStack {
                        Text("Start: \(startWeightLbs.oneDecimal) lbs")
                            .font(.system(size: Theme.captionSize))
                            .foregroundStyle(Color.appTextTertiary)
                        Spacer()
                        Text("Goal: \(Int(goalWeightLbs)) lbs")
                            .font(.system(size: Theme.captionSize))
                            .foregroundStyle(Color.appTextTertiary)
                    }
                    .padding(.horizontal, Theme.spacingXL)
                    .offset(y: -Theme.spacingSM)

                    // MARK: - Weight Progress Chart
                    WeightChartView(data: viewModel.weightHistory, goalPercent: goalPercent)
                        .padding(.horizontal, Theme.spacingLG)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(.easeOut(duration: 0.4).delay(0.15), value: appeared)

                    // MARK: - Weight Changes
                    WeightChangesCard(weightHistory: viewModel.weightHistory)
                        .padding(.horizontal, Theme.spacingLG)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(.easeOut(duration: 0.4).delay(0.25), value: appeared)

                    // MARK: - Progress Photos
                    NavigationLink {
                        ProgressPhotosView()
                    } label: {
                        progressPhotosCard
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, Theme.spacingLG)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.easeOut(duration: 0.4).delay(0.35), value: appeared)

                    // MARK: - Daily Average Calories (Nutrition Chart)
                    NutritionChartView(data: viewModel.calorieHistory)
                        .padding(.horizontal, Theme.spacingLG)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(.easeOut(duration: 0.4).delay(0.45), value: appeared)

                    // MARK: - Weekly Energy
                    WeeklyEnergyCard(calorieHistory: viewModel.calorieHistory)
                        .padding(.horizontal, Theme.spacingLG)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(.easeOut(duration: 0.4).delay(0.55), value: appeared)

                    // MARK: - BMI Card
                    if let heightCM = profile?.heightCM, heightCM > 0 {
                        BMICard(weightLbs: currentWeightLbs, heightCM: heightCM)
                            .padding(.horizontal, Theme.spacingLG)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                            .animation(.easeOut(duration: 0.4).delay(0.65), value: appeared)
                    }

                    // MARK: - Navigation Links
                    NavigationLink {
                        StrengthChartView(prs: viewModel.exercisePRs)
                    } label: {
                        navRow(icon: "trophy.fill", title: "Strength PRs", color: Color.appPRColor)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, Theme.spacingLG)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.easeOut(duration: 0.4).delay(0.75), value: appeared)

                    NavigationLink {
                        BodyMeasurementsView()
                    } label: {
                        navRow(icon: "ruler", title: "Body Measurements", color: Color.appAccent)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, Theme.spacingLG)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.easeOut(duration: 0.4).delay(0.85), value: appeared)
                }
                .padding(.vertical, Theme.spacingLG)
            }
            .screenBackground()
            .navigationTitle("Progress")
            .onAppear {
                viewModel.loadData(context: modelContext)
                withAnimation(.easeOut(duration: 0.6)) {
                    appeared = true
                }
            }
        }
    }

    // MARK: - Subviews

    private var progressPhotosCard: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            Text("Progress Photos")
                .font(.system(size: Theme.subheadlineSize, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)

            HStack(spacing: Theme.spacingMD) {
                Image(systemName: "person.crop.rectangle.badge.plus")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.appTextTertiary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Want to add a photo to track your progress?")
                        .font(.system(size: Theme.captionSize))
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                        Text("Upload a Photo")
                            .font(.system(size: Theme.captionSize, weight: .semibold))
                    }
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(.top, 4)
                }
            }
        }
        .cardStyle()
    }

    private func navRow(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: Theme.spacingMD) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color)
            Text(title)
                .font(.system(size: Theme.bodySize, weight: .medium))
                .foregroundStyle(Color.appTextPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.appTextTertiary)
        }
        .cardStyle()
    }

    private var earnedBadgeCount: Int {
        // Simplified — count streak badges earned based on current streak
        let thresholds = [3, 7, 14, 30, 60, 100]
        return thresholds.filter { streakCount >= $0 }.count
    }
}
