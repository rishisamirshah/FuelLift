import SwiftUI

struct RecipeBuilderView: View {
    @ObservedObject var nutritionViewModel: NutritionViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var recipeName = ""
    @State private var servings = "1"
    @State private var ingredients: [IngredientItem] = []
    @State private var showAddIngredient = false

    var totalCalories: Int { ingredients.reduce(0) { $0 + $1.calories } }
    var totalProtein: Double { ingredients.reduce(0) { $0 + $1.proteinG } }
    var totalCarbs: Double { ingredients.reduce(0) { $0 + $1.carbsG } }
    var totalFat: Double { ingredients.reduce(0) { $0 + $1.fatG } }

    var perServingCalories: Int {
        let s = max(Int(servings) ?? 1, 1)
        return totalCalories / s
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Recipe") {
                    TextField("Recipe name", text: $recipeName)
                    HStack {
                        Text("Servings")
                        Spacer()
                        TextField("1", text: $servings)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                    }
                }

                Section("Ingredients (\(ingredients.count))") {
                    ForEach(ingredients) { ingredient in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(ingredient.name)
                                    .font(.subheadline)
                                Text("\(ingredient.amount)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(ingredient.calories) kcal")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete { indices in
                        ingredients.remove(atOffsets: indices)
                    }

                    Button {
                        showAddIngredient = true
                    } label: {
                        Label("Add Ingredient", systemImage: "plus")
                    }
                }

                Section("Per Serving Total") {
                    HStack {
                        Text("Calories")
                        Spacer()
                        Text("\(perServingCalories) kcal").bold()
                    }
                }
            }
            .navigationTitle("Recipe Builder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveRecipe() }
                        .bold()
                        .disabled(recipeName.isEmpty || ingredients.isEmpty)
                }
            }
            .sheet(isPresented: $showAddIngredient) {
                AddIngredientSheet(ingredients: $ingredients)
            }
        }
    }

    private func saveRecipe() {
        let s = max(Int(servings) ?? 1, 1)
        let entry = FoodEntry(
            name: recipeName,
            calories: totalCalories / s,
            proteinG: totalProtein / Double(s),
            carbsG: totalCarbs / Double(s),
            fatG: totalFat / Double(s),
            servingSize: "1 serving",
            mealType: MealType.lunch.rawValue,
            source: "recipe"
        )
        nutritionViewModel.addFoodEntry(entry, context: modelContext)
        dismiss()
    }
}

struct IngredientItem: Identifiable {
    let id = UUID()
    var name: String
    var amount: String
    var calories: Int
    var proteinG: Double
    var carbsG: Double
    var fatG: Double
}

struct AddIngredientSheet: View {
    @Binding var ingredients: [IngredientItem]
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var amount = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Ingredient name", text: $name)
                TextField("Amount (e.g. 100g)", text: $amount)
                TextField("Calories", text: $calories).keyboardType(.numberPad)
                TextField("Protein (g)", text: $protein).keyboardType(.decimalPad)
                TextField("Carbs (g)", text: $carbs).keyboardType(.decimalPad)
                TextField("Fat (g)", text: $fat).keyboardType(.decimalPad)
            }
            .navigationTitle("Add Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        ingredients.append(IngredientItem(
                            name: name,
                            amount: amount,
                            calories: Int(calories) ?? 0,
                            proteinG: Double(protein) ?? 0,
                            carbsG: Double(carbs) ?? 0,
                            fatG: Double(fat) ?? 0
                        ))
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
