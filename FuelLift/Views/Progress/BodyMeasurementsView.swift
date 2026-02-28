import SwiftUI
import SwiftData

struct BodyMeasurementsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BodyMetric.date, order: .reverse) private var metrics: [BodyMetric]
    @State private var showAddSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingLG) {
                // Add button
                Button {
                    showAddSheet = true
                } label: {
                    HStack(spacing: Theme.spacingSM) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))
                        Text("Add Measurement")
                            .font(.system(size: Theme.bodySize, weight: .semibold))
                    }
                    .foregroundStyle(Color.appAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.spacingMD)
                    .background(Color.appAccent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, Theme.spacingLG)

                if metrics.isEmpty {
                    VStack(spacing: Theme.spacingMD) {
                        Image(systemName: "ruler")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.appTextTertiary)
                        Text("No measurements recorded yet.")
                            .font(.system(size: Theme.captionSize))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.spacingHuge)
                } else {
                    VStack(spacing: Theme.spacingMD) {
                        ForEach(metrics, id: \.id) { metric in
                            VStack(alignment: .leading, spacing: Theme.spacingSM) {
                                Text(metric.date.shortFormatted)
                                    .font(.system(size: Theme.bodySize, weight: .bold))
                                    .foregroundStyle(Color.appTextPrimary)

                                HStack(spacing: Theme.spacingLG) {
                                    if let w = metric.weightKG {
                                        measurementPill("Weight", "\((w * 2.20462).oneDecimal) lbs")
                                    }
                                    if let bf = metric.bodyFatPercent {
                                        measurementPill("BF%", "\(bf.oneDecimal)%")
                                    }
                                    if let chest = metric.chestCM {
                                        measurementPill("Chest", "\((chest / 2.54).oneDecimal)\"")
                                    }
                                    if let waist = metric.waistCM {
                                        measurementPill("Waist", "\((waist / 2.54).oneDecimal)\"")
                                    }
                                }
                            }
                            .cardStyle()
                        }
                    }
                    .padding(.horizontal, Theme.spacingLG)
                }
            }
            .padding(.vertical, Theme.spacingLG)
        }
        .screenBackground()
        .navigationTitle("Body Measurements")
        .sheet(isPresented: $showAddSheet) {
            AddMeasurementSheet()
        }
    }

    private func measurementPill(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: Theme.bodySize, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)
            Text(label)
                .font(.system(size: Theme.miniSize))
                .foregroundStyle(Color.appTextTertiary)
        }
        .padding(.horizontal, Theme.spacingSM)
        .padding(.vertical, Theme.spacingXS)
        .background(Color.appCardSecondary)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSM))
    }
}

struct AddMeasurementSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var weight = ""
    @State private var bodyFat = ""
    @State private var chest = ""
    @State private var waist = ""
    @State private var hips = ""
    @State private var biceps = ""
    @State private var thighs = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Body") {
                    field("Weight (lbs)", text: $weight)
                    field("Body Fat %", text: $bodyFat)
                }
                Section("Measurements (inches)") {
                    field("Chest", text: $chest)
                    field("Waist", text: $waist)
                    field("Hips", text: $hips)
                    field("Biceps", text: $biceps)
                    field("Thighs", text: $thighs)
                }
            }
            .navigationTitle("Add Measurement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }.bold()
                }
            }
        }
    }

    private func field(_ label: String, text: Binding<String>) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField("0", text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
        }
    }

    private func save() {
        let metric = BodyMetric()
        // Convert lbs to kg for storage
        if let v = Double(weight) { metric.weightKG = v / 2.20462 }
        if let v = Double(bodyFat) { metric.bodyFatPercent = v }
        // Convert inches to cm for storage
        if let v = Double(chest) { metric.chestCM = v * 2.54 }
        if let v = Double(waist) { metric.waistCM = v * 2.54 }
        if let v = Double(hips) { metric.hipsCM = v * 2.54 }
        if let v = Double(biceps) { metric.bicepsCM = v * 2.54 }
        if let v = Double(thighs) { metric.thighsCM = v * 2.54 }
        modelContext.insert(metric)
        try? modelContext.save()
        dismiss()
    }
}
