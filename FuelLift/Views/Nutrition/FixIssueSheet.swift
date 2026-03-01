import SwiftUI

struct FixIssueSheet: View {
    let entry: FoodEntry
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var issueDescription = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.spacingXL) {
                // Current info card
                VStack(alignment: .leading, spacing: Theme.spacingSM) {
                    Text("Current Analysis")
                        .font(.system(size: Theme.captionSize, weight: .semibold))
                        .foregroundStyle(Color.appTextSecondary)

                    HStack(spacing: Theme.spacingMD) {
                        if let imageData = entry.imageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSM))
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.name)
                                .font(.system(size: Theme.bodySize, weight: .medium))
                                .foregroundStyle(Color.appTextPrimary)
                            Text("\(entry.calories) cal  •  P: \(Int(entry.proteinG))g  C: \(Int(entry.carbsG))g  F: \(Int(entry.fatG))g")
                                .font(.system(size: Theme.captionSize))
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }
                }
                .cardStyle()

                // Issue description
                VStack(alignment: .leading, spacing: Theme.spacingSM) {
                    Text("What's wrong?")
                        .font(.system(size: Theme.subheadlineSize, weight: .bold))
                        .foregroundStyle(Color.appTextPrimary)

                    Text("Describe the issue and we'll re-analyze with AI.")
                        .font(.system(size: Theme.captionSize))
                        .foregroundStyle(Color.appTextSecondary)

                    TextEditor(text: $issueDescription)
                        .font(.system(size: Theme.bodySize))
                        .frame(minHeight: 100)
                        .padding(Theme.spacingSM)
                        .background(Color.appCardSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.cornerRadiusMD)
                                .stroke(Color.appBorder, lineWidth: 1)
                        )
                }
                .padding(.horizontal, Theme.spacingLG)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: Theme.captionSize))
                        .foregroundStyle(Color.appFatColor)
                        .padding(.horizontal, Theme.spacingLG)
                }

                Spacer()

                // Submit button
                Button {
                    Task { await submitFix() }
                } label: {
                    if isSubmitting {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.spacingLG)
                    } else {
                        HStack(spacing: Theme.spacingSM) {
                            Image("icon_wand_stars").pixelArt().frame(width: 20, height: 20)
                            Text("Re-analyze with AI")
                        }
                        .font(.system(size: Theme.subheadlineSize, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.spacingLG)
                    }
                }
                .background(issueDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.appTextTertiary : Color.appAccent)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                .disabled(issueDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting)
                .padding(.horizontal, Theme.spacingLG)
                .padding(.bottom, Theme.spacingLG)
            }
            .screenBackground()
            .navigationTitle("Fix Issue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.appAccent)
                }
            }
        }
    }

    private func submitFix() async {
        isSubmitting = true
        errorMessage = nil

        let originalNutrition = entry.nutrition
        let image: UIImage? = entry.imageData.flatMap { UIImage(data: $0) }

        do {
            let corrected = try await GeminiService.shared.correctFoodAnalysis(
                original: originalNutrition,
                issue: issueDescription,
                image: image
            )

            // Update entry with corrected data
            entry.name = corrected.name
            entry.calories = corrected.calories
            entry.proteinG = corrected.proteinG
            entry.carbsG = corrected.carbsG
            entry.fatG = corrected.fatG
            entry.servingSize = corrected.servingSize
            if let ingredients = corrected.ingredients,
               let data = try? JSONEncoder().encode(ingredients) {
                entry.ingredientsJSON = String(data: data, encoding: .utf8)
            }

            try? modelContext.save()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isSubmitting = false
    }
}
