import SwiftUI
import SwiftData

struct ProfileEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]

    @State private var displayName = ""
    @State private var heightCM = ""
    @State private var weightLbs = ""
    @State private var age = ""

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingLG) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.appCardSecondary)
                        .frame(width: 80, height: 80)
                    Image(systemName: "person.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.appTextSecondary)
                }
                .padding(.top, Theme.spacingXL)

                // Form fields
                VStack(spacing: 0) {
                    formField("Display Name", text: $displayName, keyboard: .default)
                    divider
                    formField("Age", text: $age, keyboard: .numberPad)
                    divider
                    formField("Height (cm)", text: $heightCM, keyboard: .decimalPad)
                    divider
                    formField("Weight (lbs)", text: $weightLbs, keyboard: .decimalPad)
                }
                .background(Color.appCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
                .padding(.horizontal, Theme.spacingLG)

                // Save button
                Button { save() } label: {
                    Text("Save")
                        .font(.system(size: Theme.subheadlineSize, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.spacingMD)
                        .background(Color.appAccent)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                }
                .padding(.horizontal, Theme.spacingLG)
            }
        }
        .screenBackground()
        .navigationTitle("Edit Profile")
        .onAppear {
            if let p = profile {
                displayName = p.displayName
                if let h = p.heightCM { heightCM = String(h) }
                if let w = p.weightKG { weightLbs = String((w * 2.20462).oneDecimal) }
                if let a = p.age { age = String(a) }
            }
        }
    }

    private func formField(_ label: String, text: Binding<String>, keyboard: UIKeyboardType) -> some View {
        HStack {
            Text(label)
                .font(.system(size: Theme.bodySize))
                .foregroundStyle(Color.appTextSecondary)
            Spacer()
            TextField("", text: text)
                .keyboardType(keyboard)
                .multilineTextAlignment(.trailing)
                .font(.system(size: Theme.bodySize, weight: .medium))
                .foregroundStyle(Color.appTextPrimary)
                .frame(width: 120)
        }
        .padding(.horizontal, Theme.spacingLG)
        .padding(.vertical, Theme.spacingMD)
    }

    private var divider: some View {
        Divider()
            .overlay(Color.appTextTertiary.opacity(0.2))
            .padding(.leading, Theme.spacingLG)
    }

    private func save() {
        guard let profile else { return }
        profile.displayName = displayName
        profile.heightCM = Double(heightCM)
        // Convert lbs to kg for storage
        if let lbs = Double(weightLbs) {
            profile.weightKG = lbs / 2.20462
        }
        profile.age = Int(age)
        profile.updatedAt = Date()
        try? modelContext.save()

        Task {
            try? await FirestoreService.shared.updateUserProfile([
                "displayName": displayName,
                "heightCM": Double(heightCM) ?? 0,
                "weightKG": (Double(weightLbs) ?? 0) / 2.20462,
                "age": Int(age) ?? 0
            ])
        }

        dismiss()
    }
}
