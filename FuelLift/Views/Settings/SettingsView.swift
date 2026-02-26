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
        List {
            Section("Profile") {
                NavigationLink {
                    ProfileEditView()
                } label: {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title)
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading) {
                            Text(profile?.displayName ?? "Your Name")
                                .font(.subheadline.bold())
                            Text(profile?.email ?? "")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("Goals") {
                NavigationLink("Edit Calorie & Macro Goals") {
                    GoalSetupView()
                }
            }

            Section("Units") {
                Picker("Measurement System", selection: $useMetric) {
                    Text("Metric (kg, cm)").tag(true)
                    Text("Imperial (lbs, in)").tag(false)
                }
            }

            Section("Integrations") {
                Toggle("Apple Health", isOn: $healthKitEnabled)
                    .onChange(of: healthKitEnabled) { _, newValue in
                        if newValue {
                            Task {
                                try? await HealthKitService.shared.requestAuthorization()
                            }
                        }
                        profile?.healthKitEnabled = newValue
                        try? modelContext.save()
                    }
            }

            Section("Notifications") {
                Toggle("Meal Reminders", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { _, newValue in
                        if !newValue {
                            NotificationService.shared.removeAllReminders()
                        }
                        profile?.notificationsEnabled = newValue
                        try? modelContext.save()
                    }

                NavigationLink("Notification Settings") {
                    NotificationSettingsView()
                }
            }

            Section("Account") {
                Button("Sign Out", role: .destructive) {
                    authViewModel.signOut()
                }

                Button("Delete Account", role: .destructive) {
                    showDeleteConfirm = true
                }
            }

            Section {
                HStack {
                    Spacer()
                    Text("FuelLift v1.0.0")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Spacer()
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            if let profile {
                useMetric = profile.useMetricUnits
                notificationsEnabled = profile.notificationsEnabled
                healthKitEnabled = profile.healthKitEnabled
            }
        }
        .alert("Delete Account?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                // In production: delete Firestore data + Firebase Auth account
                authViewModel.signOut()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete your account and all data. This cannot be undone.")
        }
    }
}
