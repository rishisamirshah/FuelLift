import SwiftUI
import SwiftData

struct UnitsSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var useMetric = true

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingLG) {
                // Segmented picker
                VStack(spacing: Theme.spacingMD) {
                    Picker("System", selection: $useMetric) {
                        Text("Metric").tag(true)
                        Text("Imperial").tag(false)
                    }
                    .pickerStyle(.segmented)
                }
                .cardStyle()
                .padding(.horizontal, Theme.spacingLG)

                // Preview
                VStack(spacing: 0) {
                    previewRow("Weight", value: useMetric ? "kg" : "lbs")
                    divider
                    previewRow("Height", value: useMetric ? "cm" : "ft/in")
                    divider
                    previewRow("Body Measurements", value: useMetric ? "cm" : "in")
                }
                .background(Color.appCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
                .padding(.horizontal, Theme.spacingLG)
            }
            .padding(.vertical, Theme.spacingLG)
        }
        .screenBackground()
        .navigationTitle("Units")
        .onAppear {
            useMetric = profile?.useMetricUnits ?? true
        }
        .onChange(of: useMetric) { _, newValue in
            profile?.useMetricUnits = newValue
            try? modelContext.save()
        }
    }

    private func previewRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: Theme.bodySize, weight: .medium))
                .foregroundStyle(Color.appTextPrimary)
            Spacer()
            Text(value)
                .font(.system(size: Theme.bodySize))
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(.horizontal, Theme.spacingLG)
        .padding(.vertical, Theme.spacingMD)
    }

    private var divider: some View {
        Divider()
            .overlay(Color.appTextTertiary.opacity(0.2))
            .padding(.leading, Theme.spacingLG)
    }
}
