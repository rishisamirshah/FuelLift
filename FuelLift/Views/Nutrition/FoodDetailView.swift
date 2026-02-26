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
        VStack(spacing: 16) {
            // Food name
            VStack(alignment: .leading, spacing: 4) {
                Text("Food")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                TextField("Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .font(.headline)
            }

            // Macros grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                nutrientField("Calories", value: $calories, unit: "kcal", color: .appCalories)
                nutrientField("Protein", value: $protein, unit: "g", color: .appProtein)
                nutrientField("Carbs", value: $carbs, unit: "g", color: .appCarbs)
                nutrientField("Fat", value: $fat, unit: "g", color: .appFat)
            }

            // Serving size
            HStack {
                Text("Serving")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                TextField("e.g. 1 cup", text: $servingSize)
                    .textFieldStyle(.roundedBorder)
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
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.orange)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding()
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
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption.bold())
                .foregroundStyle(color)
            HStack {
                TextField("0", text: value)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
