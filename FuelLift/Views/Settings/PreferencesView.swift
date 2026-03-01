import SwiftUI
import SwiftData

struct PreferencesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }

    @State private var darkModeEnabled = false
    @State private var waterGoalML: Int = 2500

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingLG) {
                // Dark Mode
                VStack(spacing: 0) {
                    HStack(spacing: Theme.spacingMD) {
                        Image("icon_moon")
                            .pixelArt()
                            .frame(width: 24, height: 24)
                        Text("Dark Mode")
                            .font(.system(size: Theme.bodySize, weight: .medium))
                            .foregroundStyle(Color.appTextPrimary)
                        Spacer()
                        Toggle("", isOn: $darkModeEnabled)
                            .labelsHidden()
                            .tint(Color.appAccent)
                    }
                    .padding(.horizontal, Theme.spacingLG)
                    .padding(.vertical, Theme.spacingMD)
                }
                .background(Color.appCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
                .padding(.horizontal, Theme.spacingLG)

                // Units
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

                // Default Water Goal
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
            }
            .padding(.vertical, Theme.spacingLG)
        }
        .screenBackground()
        .navigationTitle("Preferences")
        .onAppear {
            if let profile {
                darkModeEnabled = profile.darkModeEnabled
                waterGoalML = profile.waterGoalML
            }
        }
        .onChange(of: darkModeEnabled) { _, newValue in
            profile?.darkModeEnabled = newValue
            try? modelContext.save()
        }
        .onChange(of: waterGoalML) { _, newValue in
            profile?.waterGoalML = newValue
            try? modelContext.save()
        }
    }
}
