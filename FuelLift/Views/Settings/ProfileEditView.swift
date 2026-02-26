import SwiftUI
import SwiftData

struct ProfileEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]

    @State private var displayName = ""
    @State private var heightCM = ""
    @State private var weightKG = ""
    @State private var age = ""

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        Form {
            Section("Personal Info") {
                TextField("Display Name", text: $displayName)
                LabeledField(label: "Age", text: $age, placeholder: "25", keyboard: .numberPad)
                LabeledField(label: "Height (cm)", text: $heightCM, placeholder: "175", keyboard: .decimalPad)
                LabeledField(label: "Weight (kg)", text: $weightKG, placeholder: "75", keyboard: .decimalPad)
            }
        }
        .navigationTitle("Edit Profile")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") { save() }.bold()
            }
        }
        .onAppear {
            if let p = profile {
                displayName = p.displayName
                if let h = p.heightCM { heightCM = String(h) }
                if let w = p.weightKG { weightKG = String(w) }
                if let a = p.age { age = String(a) }
            }
        }
    }

    private func save() {
        guard let profile else { return }
        profile.displayName = displayName
        profile.heightCM = Double(heightCM)
        profile.weightKG = Double(weightKG)
        profile.age = Int(age)
        profile.updatedAt = Date()
        try? modelContext.save()

        Task {
            try? await FirestoreService.shared.updateUserProfile([
                "displayName": displayName,
                "heightCM": Double(heightCM) ?? 0,
                "weightKG": Double(weightKG) ?? 0,
                "age": Int(age) ?? 0
            ])
        }

        dismiss()
    }
}
