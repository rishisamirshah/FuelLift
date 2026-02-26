import SwiftUI
import SwiftData

struct BodyMeasurementsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BodyMetric.date, order: .reverse) private var metrics: [BodyMetric]
    @State private var showAddSheet = false

    var body: some View {
        List {
            Section {
                Button {
                    showAddSheet = true
                } label: {
                    Label("Add Measurement", systemImage: "plus.circle.fill")
                        .foregroundStyle(.orange)
                }
            }

            Section("History") {
                if metrics.isEmpty {
                    Text("No measurements recorded yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(metrics, id: \.id) { metric in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(metric.date.shortFormatted)
                                .font(.subheadline.bold())
                            HStack(spacing: 16) {
                                if let w = metric.weightKG { measurementLabel("Weight", "\(w.oneDecimal) kg") }
                                if let bf = metric.bodyFatPercent { measurementLabel("BF%", "\(bf.oneDecimal)%") }
                                if let chest = metric.chestCM { measurementLabel("Chest", "\(chest.oneDecimal)") }
                                if let waist = metric.waistCM { measurementLabel("Waist", "\(waist.oneDecimal)") }
                            }
                        }
                    }
                    .onDelete { indices in
                        for index in indices {
                            modelContext.delete(metrics[index])
                        }
                        try? modelContext.save()
                    }
                }
            }
        }
        .navigationTitle("Body Measurements")
        .sheet(isPresented: $showAddSheet) {
            AddMeasurementSheet()
        }
    }

    private func measurementLabel(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.caption.bold())
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
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
                    field("Weight (kg)", text: $weight)
                    field("Body Fat %", text: $bodyFat)
                }
                Section("Measurements (cm)") {
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
        if let v = Double(weight) { metric.weightKG = v }
        if let v = Double(bodyFat) { metric.bodyFatPercent = v }
        if let v = Double(chest) { metric.chestCM = v }
        if let v = Double(waist) { metric.waistCM = v }
        if let v = Double(hips) { metric.hipsCM = v }
        if let v = Double(biceps) { metric.bicepsCM = v }
        if let v = Double(thighs) { metric.thighsCM = v }
        modelContext.insert(metric)
        try? modelContext.save()
        dismiss()
    }
}
