import SwiftUI

struct ManualFoodEntryView: View {
    @ObservedObject var nutritionViewModel: NutritionViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    @State private var servingSize = ""
    @State private var mealType: MealType = .snack

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacingLG) {
                    // Food details section
                    VStack(alignment: .leading, spacing: Theme.spacingMD) {
                        Text("Food Details")
                            .font(.system(size: Theme.subheadlineSize, weight: .bold))
                            .foregroundStyle(Color.appTextPrimary)

                        formField(label: "Food name", text: $name, placeholder: "e.g. Chicken breast")

                        // Meal type picker
                        VStack(alignment: .leading, spacing: Theme.spacingXS) {
                            Text("Meal")
                                .font(.system(size: Theme.captionSize, weight: .bold))
                                .foregroundStyle(Color.appTextSecondary)
                            Picker("Meal", selection: $mealType) {
                                ForEach(MealType.allCases) { type in
                                    Text(type.displayName).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        formField(label: "Serving size", text: $servingSize, placeholder: "e.g. 1 cup, 200g")
                    }
                    .cardStyle()

                    // Nutrition section
                    VStack(alignment: .leading, spacing: Theme.spacingMD) {
                        Text("Nutrition")
                            .font(.system(size: Theme.subheadlineSize, weight: .bold))
                            .foregroundStyle(Color.appTextPrimary)

                        nutrientRow(label: "Calories", text: $calories, unit: "kcal", color: Color.appCaloriesColor)
                        nutrientRow(label: "Protein", text: $protein, unit: "g", color: Color.appProteinColor)
                        nutrientRow(label: "Carbs", text: $carbs, unit: "g", color: Color.appCarbsColor)
                        nutrientRow(label: "Fat", text: $fat, unit: "g", color: Color.appFatColor)
                    }
                    .cardStyle()

                    // Save button
                    Button {
                        saveEntry()
                    } label: {
                        Text("Add to Log")
                            .font(.system(size: Theme.subheadlineSize, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(Theme.spacingLG)
                            .background(name.isEmpty ? Color.appTextTertiary : Color.appAccent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                    }
                    .disabled(name.isEmpty)
                }
                .padding(Theme.spacingLG)
            }
            .screenBackground()
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.appAccent)
                }
            }
        }
    }

    // MARK: - Components

    private func formField(label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingXS) {
            Text(label)
                .font(.system(size: Theme.captionSize, weight: .bold))
                .foregroundStyle(Color.appTextSecondary)
            TextField(placeholder, text: text)
                .font(.system(size: Theme.bodySize))
                .foregroundStyle(Color.appTextPrimary)
                .padding(Theme.spacingMD)
                .background(Color.appCardSecondary)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSM))
        }
    }

    private func nutrientRow(label: String, text: Binding<String>, unit: String, color: Color) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: Theme.bodySize, weight: .medium))
                .foregroundStyle(Color.appTextPrimary)
            Spacer()
            TextField("0", text: text)
                .keyboardType(unit == "kcal" ? .numberPad : .decimalPad)
                .multilineTextAlignment(.trailing)
                .font(.system(size: Theme.bodySize, weight: .medium, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)
                .frame(width: 80)
                .padding(.horizontal, Theme.spacingSM)
                .padding(.vertical, Theme.spacingXS)
                .background(Color.appCardSecondary)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSM))
            Text(unit)
                .font(.system(size: Theme.captionSize))
                .foregroundStyle(Color.appTextSecondary)
                .frame(width: 30, alignment: .leading)
        }
    }

    // MARK: - Save

    private func saveEntry() {
        let entry = FoodEntry(
            name: name,
            calories: Int(calories) ?? 0,
            proteinG: Double(protein) ?? 0,
            carbsG: Double(carbs) ?? 0,
            fatG: Double(fat) ?? 0,
            servingSize: servingSize,
            mealType: mealType.rawValue,
            source: "manual"
        )
        nutritionViewModel.addFoodEntry(entry, context: modelContext)
        dismiss()
    }
}
