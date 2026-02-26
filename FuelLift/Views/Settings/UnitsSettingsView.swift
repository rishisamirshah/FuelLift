import SwiftUI
import SwiftData

struct UnitsSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var useMetric = true

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        Form {
            Section {
                Picker("System", selection: $useMetric) {
                    Text("Metric").tag(true)
                    Text("Imperial").tag(false)
                }
                .pickerStyle(.segmented)
            }

            Section("Preview") {
                HStack {
                    Text("Weight")
                    Spacer()
                    Text(useMetric ? "kg" : "lbs")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Height")
                    Spacer()
                    Text(useMetric ? "cm" : "ft/in")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Body Measurements")
                    Spacer()
                    Text(useMetric ? "cm" : "in")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Units")
        .onAppear {
            useMetric = profile?.useMetricUnits ?? true
        }
        .onChange(of: useMetric) { _, newValue in
            profile?.useMetricUnits = newValue
            try? modelContext.save()
        }
    }
}
