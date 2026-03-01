import SwiftUI
import SwiftData

struct FoodDescriptionView: View {
    @ObservedObject var nutritionViewModel: NutritionViewModel
    @StateObject private var scanVM = FoodScanViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacingXL) {
                    if scanVM.isAnalyzing {
                        // Analyzing state
                        Spacer()
                        VStack(spacing: Theme.spacingMD) {
                            ProgressView()
                                .controlSize(.large)
                                .tint(Color.appAccent)
                            Text("Analyzing your food...")
                                .font(.system(size: Theme.bodySize))
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        .padding(Theme.spacingHuge)
                        Spacer()
                    } else if let nutrition = scanVM.scannedNutrition {
                        // Show nutrition result for confirmation
                        FoodDetailView(
                            nutrition: nutrition,
                            mealType: $scanVM.selectedMealType,
                            onSave: { finalNutrition, mealType in
                                let entry = FoodEntry(
                                    name: finalNutrition.name,
                                    calories: finalNutrition.calories,
                                    proteinG: finalNutrition.proteinG,
                                    carbsG: finalNutrition.carbsG,
                                    fatG: finalNutrition.fatG,
                                    servingSize: finalNutrition.servingSize,
                                    mealType: mealType.rawValue,
                                    source: "ai_description"
                                )
                                if let ingredients = finalNutrition.ingredients,
                                   let data = try? JSONEncoder().encode(ingredients) {
                                    entry.ingredientsJSON = String(data: data, encoding: .utf8)
                                }
                                nutritionViewModel.addFoodEntry(entry, context: modelContext)
                                dismiss()
                            }
                        )
                    } else {
                        // Text input state
                        VStack(spacing: Theme.spacingLG) {
                            Image("icon_text_bubble").resizable().renderingMode(.original).interpolation(.none).aspectRatio(contentMode: .fit)
                                .frame(width: 48, height: 48)
                                .opacity(0.5)
                                .padding(.top, Theme.spacingHuge)

                            Text("Describe what you ate")
                                .font(.system(size: Theme.headlineSize, weight: .bold))
                                .foregroundStyle(Color.appTextPrimary)

                            Text("Our AI will estimate the nutrition info.")
                                .font(.system(size: Theme.bodySize))
                                .foregroundStyle(Color.appTextSecondary)
                        }

                        // Text editor
                        ZStack(alignment: .topLeading) {
                            if scanVM.foodDescription.isEmpty {
                                Text("e.g. grilled chicken breast 200g with a cup of white rice and steamed broccoli")
                                    .font(.system(size: Theme.bodySize))
                                    .foregroundStyle(Color.appTextTertiary)
                                    .padding(.horizontal, Theme.spacingMD + 4)
                                    .padding(.vertical, Theme.spacingMD + 8)
                            }

                            TextEditor(text: $scanVM.foodDescription)
                                .font(.system(size: Theme.bodySize))
                                .foregroundStyle(Color.appTextPrimary)
                                .scrollContentBackground(.hidden)
                                .padding(Theme.spacingSM)
                                .frame(minHeight: 120)
                        }
                        .background(Color.appCardSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                        .padding(.horizontal, Theme.spacingLG)

                        // Analyze button
                        Button {
                            Task { await scanVM.analyzeDescription() }
                        } label: {
                            Label {
                                Text("Analyze with AI")
                                    .font(.system(size: Theme.subheadlineSize, weight: .bold))
                            } icon: {
                                Image("icon_wand_stars").resizable().renderingMode(.original).interpolation(.none).aspectRatio(contentMode: .fit).frame(width: 24, height: 24)
                            }
                                .frame(maxWidth: .infinity)
                                .padding(Theme.spacingLG)
                                .background(Color.appAccent)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                        }
                        .disabled(scanVM.foodDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(scanVM.foodDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                        .padding(.horizontal, Theme.spacingLG)
                    }
                }
                .padding(.vertical, Theme.spacingLG)
            }
            .screenBackground()
            .navigationTitle("Describe Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.appAccent)
                }
            }
            .alert("Error", isPresented: $scanVM.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(scanVM.errorMessage ?? "Unknown error")
            }
        }
    }
}
