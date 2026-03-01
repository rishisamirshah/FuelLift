import SwiftUI
import SwiftData

struct PreferencesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }

    @State private var appearanceMode = "auto"
    @State private var waterGoalML: Int = 2500
    @State private var enableBadgeCelebrations = true
    @State private var enableLiveActivity = false
    @State private var addBurnedCalories = false
    @State private var rolloverCalories = false

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingXL) {
                // MARK: - Appearance (Visual Cards)
                VStack(alignment: .leading, spacing: Theme.spacingMD) {
                    Text("Appearance")
                        .font(.system(size: Theme.subheadlineSize, weight: .bold))
                        .foregroundStyle(Color.appTextPrimary)
                        .padding(.horizontal, Theme.spacingLG)

                    HStack(spacing: Theme.spacingMD) {
                        appearanceCard(mode: "light", label: "Light", icon: "sun.max.fill")
                        appearanceCard(mode: "dark", label: "Dark", icon: "moon.fill")
                        appearanceCard(mode: "auto", label: "Auto", icon: "circle.lefthalf.filled")
                    }
                    .padding(.horizontal, Theme.spacingLG)
                }

                // MARK: - Feature Toggles
                VStack(spacing: 0) {
                    toggleRow(
                        icon: "party.popper.fill",
                        title: "Badge Celebrations",
                        subtitle: "Confetti when earning badges",
                        isOn: $enableBadgeCelebrations
                    )

                    Divider().padding(.horizontal, Theme.spacingLG)

                    toggleRow(
                        icon: "lock.display",
                        title: "Live Activity",
                        subtitle: "Show calories on lock screen",
                        isOn: $enableLiveActivity
                    )

                    Divider().padding(.horizontal, Theme.spacingLG)

                    toggleRow(
                        icon: "flame.fill",
                        title: "Add Burned Calories",
                        subtitle: "Add HealthKit active calories to daily budget",
                        isOn: $addBurnedCalories
                    )

                    Divider().padding(.horizontal, Theme.spacingLG)

                    toggleRow(
                        icon: "arrow.uturn.forward",
                        title: "Rollover Calories",
                        subtitle: "Unused calories carry to next day",
                        isOn: $rolloverCalories
                    )
                }
                .background(Color.appCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
                .padding(.horizontal, Theme.spacingLG)

                // MARK: - Water Goal
                VStack(spacing: 0) {
                    HStack(spacing: Theme.spacingMD) {
                        Image("icon_water_drop")
                            .pixelArt()
                            .frame(width: 24, height: 24)
                        Text("Default Water Goal (mL)")
                            .font(.system(size: Theme.bodySize, weight: .medium))
                            .foregroundStyle(Color.appTextPrimary)
                        Spacer()
                        Text("\(waterGoalML)")
                            .font(.system(size: Theme.bodySize, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.appAccent)
                    }
                    .padding(.horizontal, Theme.spacingLG)
                    .padding(.vertical, Theme.spacingMD)

                    Stepper("", value: $waterGoalML, in: 500...5000, step: 250)
                        .labelsHidden()
                        .padding(.horizontal, Theme.spacingLG)
                        .padding(.bottom, Theme.spacingMD)
                }
                .background(Color.appCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
                .padding(.horizontal, Theme.spacingLG)

                // MARK: - Units
                VStack(spacing: 0) {
                    NavigationLink {
                        UnitsSettingsView()
                    } label: {
                        HStack(spacing: Theme.spacingMD) {
                            Image("icon_ruler")
                                .pixelArt()
                                .frame(width: 24, height: 24)
                            Text("Units")
                                .font(.system(size: Theme.bodySize, weight: .medium))
                                .foregroundStyle(Color.appTextPrimary)
                            Spacer()
                            Image("icon_chevron_right")
                                .pixelArt()
                                .frame(width: 14, height: 14)
                        }
                        .padding(.horizontal, Theme.spacingLG)
                        .padding(.vertical, Theme.spacingMD)
                    }
                    .buttonStyle(.plain)
                }
                .background(Color.appCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
                .padding(.horizontal, Theme.spacingLG)
            }
            .padding(.vertical, Theme.spacingLG)
        }
        .screenBackground()
        .navigationTitle("Preferences")
        .onAppear {
            if let profile {
                appearanceMode = profile.appearanceMode
                waterGoalML = profile.waterGoalML
                enableBadgeCelebrations = profile.enableBadgeCelebrations
                enableLiveActivity = profile.enableLiveActivity
                addBurnedCalories = profile.addBurnedCalories
                rolloverCalories = profile.rolloverCalories
            }
        }
        .onChange(of: appearanceMode) { _, newValue in
            profile?.appearanceMode = newValue
            try? modelContext.save()
        }
        .onChange(of: waterGoalML) { _, newValue in
            profile?.waterGoalML = newValue
            try? modelContext.save()
        }
        .onChange(of: enableBadgeCelebrations) { _, newValue in
            profile?.enableBadgeCelebrations = newValue
            try? modelContext.save()
        }
        .onChange(of: enableLiveActivity) { _, newValue in
            profile?.enableLiveActivity = newValue
            try? modelContext.save()
        }
        .onChange(of: addBurnedCalories) { _, newValue in
            profile?.addBurnedCalories = newValue
            try? modelContext.save()
        }
        .onChange(of: rolloverCalories) { _, newValue in
            profile?.rolloverCalories = newValue
            try? modelContext.save()
        }
    }

    // MARK: - Appearance Card

    private func appearanceCard(mode: String, label: String, icon: String) -> some View {
        let isSelected = appearanceMode == mode

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                appearanceMode = mode
            }
        } label: {
            VStack(spacing: Theme.spacingMD) {
                // Mini app preview
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.cornerRadiusSM)
                        .fill(mode == "dark" ? Color(white: 0.08) : (mode == "light" ? Color(white: 0.96) : Color.appCardSecondary))
                        .frame(height: 80)

                    VStack(spacing: 6) {
                        // Mini ring
                        Circle()
                            .stroke(mode == "dark" ? Color.appCaloriesColor : (mode == "light" ? Color.appCaloriesColor.opacity(0.8) : Color.appCaloriesColor), lineWidth: 3)
                            .frame(width: 28, height: 28)

                        // Mini bars
                        HStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.appProteinColor)
                                .frame(width: 16, height: 6)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.appCarbsColor)
                                .frame(width: 16, height: 6)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.appFatColor)
                                .frame(width: 16, height: 6)
                        }
                    }
                }

                // Icon + label
                HStack(spacing: Theme.spacingSM) {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(isSelected ? Color.appAccent : Color.appTextSecondary)
                    Text(label)
                        .font(.system(size: Theme.captionSize, weight: .semibold))
                        .foregroundStyle(isSelected ? Color.appTextPrimary : Color.appTextSecondary)
                }
            }
            .padding(Theme.spacingMD)
            .background(Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusMD)
                    .stroke(isSelected ? Color.appAccent : Color.appBorder, lineWidth: isSelected ? 2 : 1)
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.appAccent)
                        .background(Circle().fill(Color.appCardBackground).frame(width: 14, height: 14))
                        .offset(x: 6, y: -6)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Toggle Row

    private func toggleRow(icon: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: Theme.spacingMD) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color.appAccent)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: Theme.bodySize, weight: .medium))
                    .foregroundStyle(Color.appTextPrimary)
                Text(subtitle)
                    .font(.system(size: Theme.captionSize))
                    .foregroundStyle(Color.appTextSecondary)
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color.appAccent)
        }
        .padding(.horizontal, Theme.spacingLG)
        .padding(.vertical, Theme.spacingMD)
    }
}
