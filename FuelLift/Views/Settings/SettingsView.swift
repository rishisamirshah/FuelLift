import SwiftUI
import SwiftData

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    @State private var useMetric = true
    @State private var notificationsEnabled = true
    @State private var healthKitEnabled = false
    @State private var showDeleteConfirm = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingXXL) {
                // MARK: - Profile Header
                NavigationLink {
                    ProfileEditView()
                } label: {
                    HStack(spacing: Theme.spacingMD) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(Color.appCardSecondary)
                                .frame(width: 56, height: 56)
                            Image("icon_person")
                                .resizable()
                                .renderingMode(.original)
                                .interpolation(.none)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 28, height: 28)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(profile?.displayName.isEmpty == false ? profile!.displayName : "Your Name")
                                .font(.system(size: Theme.subheadlineSize, weight: .bold))
                                .foregroundStyle(Color.appTextPrimary)
                            Text("@\(profile?.displayName.lowercased().replacingOccurrences(of: " ", with: "") ?? "user")")
                                .font(.system(size: Theme.captionSize))
                                .foregroundStyle(Color.appTextSecondary)
                        }

                        Spacer()

                        Image("icon_chevron_right")
                            .resizable()
                            .renderingMode(.original)
                            .interpolation(.none)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 14, height: 14)
                    }
                    .padding(Theme.spacingLG)
                    .background(Color.appCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, Theme.spacingLG)

                // MARK: - Account Section
                sectionHeader("Account")
                    .padding(.horizontal, Theme.spacingLG)

                VStack(spacing: 0) {
                    settingsRow(pixelIcon: "icon_person", title: "Personal Details") {
                        ProfileEditView()
                    }
                    divider()
                    settingsRow(pixelIcon: "icon_gear", title: "Preferences") {
                        PreferencesView()
                    }
                    divider()
                    settingsRow(pixelIcon: "icon_ruler", title: "Units") {
                        UnitsSettingsView()
                    }
                }
                .background(Color.appCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
                .padding(.horizontal, Theme.spacingLG)

                // MARK: - Preferences
                sectionHeader("Preferences")
                    .padding(.horizontal, Theme.spacingLG)

                VStack(spacing: 0) {
                    HStack(spacing: Theme.spacingMD) {
                        Image("icon_moon")
                            .resizable()
                            .renderingMode(.original)
                            .interpolation(.none)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                        Text("Dark Mode")
                            .font(.system(size: Theme.bodySize, weight: .medium))
                            .foregroundStyle(Color.appTextPrimary)
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { profile?.darkModeEnabled ?? false },
                            set: { newValue in
                                profile?.darkModeEnabled = newValue
                                try? modelContext.save()
                            }
                        ))
                        .labelsHidden()
                        .tint(Color.appAccent)
                    }
                    .padding(.horizontal, Theme.spacingLG)
                    .padding(.vertical, Theme.spacingMD)
                }
                .background(Color.appCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
                .padding(.horizontal, Theme.spacingLG)

                // MARK: - Dashboard Display
                sectionHeader("Customize Dashboard")
                    .padding(.horizontal, Theme.spacingLG)

                VStack(spacing: 0) {
                    dashboardToggle("Streak Badge", pixelIcon: "icon_fire_streak",
                                    isOn: Binding(
                                        get: { profile?.showStreakBadge ?? true },
                                        set: { profile?.showStreakBadge = $0; try? modelContext.save() }
                                    ))
                    divider()
                    dashboardToggle("Quick Actions", pixelIcon: "icon_bolt",
                                    isOn: Binding(
                                        get: { profile?.showQuickActions ?? true },
                                        set: { profile?.showQuickActions = $0; try? modelContext.save() }
                                    ))
                    divider()
                    dashboardToggle("Macros Breakdown", pixelIcon: "icon_pie_chart",
                                    isOn: Binding(
                                        get: { profile?.showMacrosBreakdown ?? true },
                                        set: { profile?.showMacrosBreakdown = $0; try? modelContext.save() }
                                    ))
                    divider()
                    dashboardToggle("Water Tracker", pixelIcon: "icon_water_drop",
                                    isOn: Binding(
                                        get: { profile?.showWaterTracker ?? true },
                                        set: { profile?.showWaterTracker = $0; try? modelContext.save() }
                                    ))
                    divider()
                    dashboardToggle("Workout Summary", pixelIcon: "icon_dumbbell",
                                    isOn: Binding(
                                        get: { profile?.showWorkoutSummary ?? true },
                                        set: { profile?.showWorkoutSummary = $0; try? modelContext.save() }
                                    ))
                }
                .background(Color.appCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
                .padding(.horizontal, Theme.spacingLG)

                // MARK: - Goals & Tracking
                sectionHeader("Goals & Tracking")
                    .padding(.horizontal, Theme.spacingLG)

                VStack(spacing: 0) {
                    // Apple Health row
                    HStack(spacing: Theme.spacingMD) {
                        Image("icon_heart")
                            .resizable()
                            .renderingMode(.original)
                            .interpolation(.none)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                        Text("Apple Health")
                            .font(.system(size: Theme.bodySize, weight: .medium))
                            .foregroundStyle(Color.appTextPrimary)
                        Spacer()
                        if healthKitEnabled {
                            Text("Connected")
                                .font(.system(size: Theme.captionSize))
                                .foregroundStyle(Color.appCaloriesColor)
                        }
                        Toggle("", isOn: $healthKitEnabled)
                            .labelsHidden()
                            .tint(Color.appAccent)
                    }
                    .padding(.horizontal, Theme.spacingLG)
                    .padding(.vertical, Theme.spacingMD)

                    divider()

                    settingsRow(pixelIcon: "icon_target", title: "Reset AI Plan") {
                        NutritionPlanView()
                    }

                    divider()

                    settingsRow(pixelIcon: "icon_bell", title: "Notifications") {
                        NotificationSettingsView()
                    }
                }
                .background(Color.appCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
                .padding(.horizontal, Theme.spacingLG)

                // MARK: - Social
                sectionHeader("Social")
                    .padding(.horizontal, Theme.spacingLG)

                VStack(spacing: 0) {
                    settingsRow(pixelIcon: "icon_person_group", title: "Groups") {
                        GroupsListView()
                    }
                }
                .background(Color.appCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
                .padding(.horizontal, Theme.spacingLG)

                // MARK: - Danger Zone
                VStack(spacing: 0) {
                    Button {
                        authViewModel.signOut()
                    } label: {
                        HStack {
                            Text("Sign Out")
                                .font(.system(size: Theme.bodySize, weight: .medium))
                                .foregroundStyle(Color.appFatColor)
                            Spacer()
                        }
                        .padding(.horizontal, Theme.spacingLG)
                        .padding(.vertical, Theme.spacingMD)
                    }
                    .buttonStyle(.plain)

                    divider()

                    Button {
                        showDeleteConfirm = true
                    } label: {
                        HStack {
                            Text("Delete Account")
                                .font(.system(size: Theme.bodySize, weight: .medium))
                                .foregroundStyle(Color.appFatColor)
                            Spacer()
                        }
                        .padding(.horizontal, Theme.spacingLG)
                        .padding(.vertical, Theme.spacingMD)
                    }
                    .buttonStyle(.plain)
                }
                .background(Color.appCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
                .padding(.horizontal, Theme.spacingLG)

                // Version
                Text("FuelLift v1.0.0")
                    .font(.system(size: Theme.miniSize))
                    .foregroundStyle(Color.appTextTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.spacingLG)
            }
            .padding(.vertical, Theme.spacingLG)
        }
        .screenBackground()
        .navigationTitle("Profile")
        .onAppear {
            if let profile {
                useMetric = profile.useMetricUnits
                notificationsEnabled = profile.notificationsEnabled
                healthKitEnabled = profile.healthKitEnabled
            }
        }
        .onChange(of: healthKitEnabled) { _, newValue in
            if newValue {
                Task {
                    try? await HealthKitService.shared.requestAuthorization()
                }
            }
            profile?.healthKitEnabled = newValue
            try? modelContext.save()
        }
        .alert("Delete Account?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                authViewModel.signOut()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete your account and all data. This cannot be undone.")
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: Theme.captionSize, weight: .semibold))
            .foregroundStyle(Color.appTextSecondary)
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func settingsRow<Destination: View>(pixelIcon: String, title: String, @ViewBuilder destination: () -> Destination) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: Theme.spacingMD) {
                Image(pixelIcon)
                    .resizable()
                    .renderingMode(.original)
                    .interpolation(.none)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                Text(title)
                    .font(.system(size: Theme.bodySize, weight: .medium))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Image("icon_chevron_right")
                    .resizable()
                    .renderingMode(.original)
                    .interpolation(.none)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 14, height: 14)
            }
            .padding(.horizontal, Theme.spacingLG)
            .padding(.vertical, Theme.spacingMD)
        }
        .buttonStyle(.plain)
    }

    private func dashboardToggle(_ title: String, pixelIcon: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: Theme.spacingMD) {
            Image(pixelIcon)
                .resizable()
                .renderingMode(.original)
                .interpolation(.none)
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
            Text(title)
                .font(.system(size: Theme.bodySize, weight: .medium))
                .foregroundStyle(Color.appTextPrimary)
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color.appAccent)
        }
        .padding(.horizontal, Theme.spacingLG)
        .padding(.vertical, Theme.spacingMD)
    }

    private func divider() -> some View {
        Divider()
            .overlay(Color.appTextTertiary.opacity(0.2))
            .padding(.leading, 56)
    }
}
