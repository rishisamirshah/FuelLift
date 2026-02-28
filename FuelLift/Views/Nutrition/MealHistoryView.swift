import SwiftUI
import SwiftData

struct MealHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FoodEntry.date, order: .reverse) private var allEntries: [FoodEntry]
    @ObservedObject var nutritionViewModel: NutritionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""

    var filteredEntries: [FoodEntry] {
        if searchText.isEmpty { return Array(allEntries.prefix(100)) }
        return allEntries.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var uniqueFoods: [FoodEntry] {
        var seen = Set<String>()
        return filteredEntries.filter { entry in
            let key = entry.name.lowercased()
            if seen.contains(key) { return false }
            seen.insert(key)
            return true
        }
    }

    var body: some View {
        NavigationStack {
            List(uniqueFoods, id: \.id) { entry in
                Button {
                    relogEntry(entry)
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(entry.name)
                                .font(.system(size: Theme.bodySize))
                            Text("\(entry.calories) kcal · \(entry.servingSize)")
                                .font(.system(size: Theme.captionSize))
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        Spacer()
                        Image(systemName: "plus.circle")
                            .foregroundStyle(Color.appAccent)
                    }
                }
                .buttonStyle(.plain)
            }
            .searchable(text: $searchText, prompt: "Search past meals")
            .navigationTitle("Meal History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func relogEntry(_ original: FoodEntry) {
        let entry = FoodEntry(
            name: original.name,
            calories: original.calories,
            proteinG: original.proteinG,
            carbsG: original.carbsG,
            fatG: original.fatG,
            servingSize: original.servingSize,
            mealType: original.mealType,
            source: "relog"
        )
        nutritionViewModel.addFoodEntry(entry, context: modelContext)
        dismiss()
    }
}
