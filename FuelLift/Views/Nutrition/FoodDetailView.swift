import SwiftUI

struct FoodDetailView: View {
    let nutrition: NutritionData
    @Binding var mealType: MealType
    let onSave: (NutritionData, MealType) -> Void

    @State private var name: String = ""
    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var carbs: String = ""
    @State private var fat: String = ""
    @State private var servingSize: String = ""

    var body: some View {
        VStack(spacing: Theme.spacingLG) {
            // Food name
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text("Food")
                    .font(.system(size: Theme.captionSize, weight: .bold))
                    .foregroundStyle(Color.appTextSecondary)
                TextField("Name", text: $name)
                    .font(.system(size: Theme.subheadlineSize, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(Theme.spacingMD)
                    .background(Color.appCardSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSM))
            }

            // Macro grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.spacingMD) {
                nutrientField("Calories", value: $calories, unit: "kcal", color: Color.appCaloriesColor)
                nutrientField("Protein", value: $protein, unit: "g", color: Color.appProteinColor)
                nutrientField("Carbs", value: $carbs, unit: "g", color: Color.appCarbsColor)
                nutrientField("Fat", value: $fat, unit: "g", color: Color.appFatColor)
            }

            // Serving size
            HStack(spacing: Theme.spacingSM) {
                Text("Serving")
                    .font(.system(size: Theme.captionSize, weight: .bold))
                    .foregroundStyle(Color.appTextSecondary)
                TextField("e.g. 1 cup", text: $servingSize)
                    .font(.system(size: Theme.bodySize))
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(Theme.spacingMD)
                    .background(Color.appCardSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSM))
            }

            // Meal type picker
            Picker("Meal", selection: $mealType) {
                ForEach(MealType.allCases) { type in
                    Label(type.displayName, systemImage: type.icon).tag(type)
                }
            }
            .pickerStyle(.segmented)

            // Save button
            Button {
                let finalNutrition = NutritionData(
                    name: name,
                    calories: Int(calories) ?? 0,
                    proteinG: Double(protein) ?? 0,
                    carbsG: Double(carbs) ?? 0,
                    fatG: Double(fat) ?? 0,
                    servingSize: servingSize
                )
                onSave(finalNutrition, mealType)
            } label: {
                Text("Add to Log")
                    .font(.system(size: Theme.subheadlineSize, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(Theme.spacingLG)
                    .background(Color.appAccent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
            }
        }
        .padding(Theme.spacingLG)
        .onAppear {
            name = nutrition.name
            calories = String(nutrition.calories)
            protein = String(nutrition.proteinG)
            carbs = String(nutrition.carbsG)
            fat = String(nutrition.fatG)
            servingSize = nutrition.servingSize
        }
    }

    private func nutrientField(_ label: String, value: Binding<String>, unit: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingXS) {
            Text(label)
                .font(.system(size: Theme.captionSize, weight: .bold))
                .foregroundStyle(color)
            HStack(spacing: Theme.spacingXS) {
                TextField("0", text: value)
                    .keyboardType(.decimalPad)
                    .font(.system(size: Theme.bodySize, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(Theme.spacingMD)
                    .background(Color.appCardSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSM))
                Text(unit)
                    .font(.system(size: Theme.captionSize))
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
    }
}
