import SwiftUI
import SwiftData

struct FoodLogView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = NutritionViewModel()
    @State private var showAddSheet = false
    @State private var showCamera = false
    @State private var showBarcode = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Date picker
                    DatePicker("Date", selection: $viewModel.selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding(.horizontal)
                        .onChange(of: viewModel.selectedDate) { _, _ in
                            viewModel.loadEntries(context: modelContext)
                        }

                    // Daily summary card
                    dailySummaryCard

                    // Water tracker
                    waterCard

                    // Meals
                    ForEach(MealType.allCases) { mealType in
                        mealSection(mealType)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Nutrition")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button { showCamera = true } label: {
                            Label("Scan Food Photo", systemImage: "camera.fill")
                        }
                        Button { showBarcode = true } label: {
                            Label("Scan Barcode", systemImage: "barcode.viewfinder")
                        }
                        Button { showAddSheet = true } label: {
                            Label("Manual Entry", systemImage: "pencil")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraScanView(nutritionViewModel: viewModel)
            }
            .sheet(isPresented: $showBarcode) {
                BarcodeScanView(nutritionViewModel: viewModel)
            }
            .sheet(isPresented: $showAddSheet) {
                ManualFoodEntryView(nutritionViewModel: viewModel)
            }
            .onAppear {
                viewModel.loadEntries(context: modelContext)
            }
        }
    }

    // MARK: - Daily Summary

    private var dailySummaryCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(viewModel.totalCalories)")
                        .font(.title.bold())
                    Text("calories eaten")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            HStack(spacing: 20) {
                macroItem("Protein", value: viewModel.totalProtein, color: .appProtein)
                macroItem("Carbs", value: viewModel.totalCarbs, color: .appCarbs)
                macroItem("Fat", value: viewModel.totalFat, color: .appFat)
            }
        }
        .cardStyle()
        .padding(.horizontal)
    }

    private func macroItem(_ label: String, value: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value.oneDecimal + "g")
                .font(.headline)
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Water Card

    private var waterCard: some View {
        HStack {
            Image(systemName: "drop.fill")
                .foregroundStyle(.appWater)
            Text("\(viewModel.totalWaterML) mL")
                .font(.headline)
            Spacer()

            ForEach([250, 500], id: \.self) { amount in
                Button("+\(amount)") {
                    viewModel.addWater(amountML: amount, context: modelContext)
                }
                .buttonStyle(.bordered)
                .tint(.cyan)
                .controlSize(.small)
            }
        }
        .cardStyle()
        .padding(.horizontal)
    }

    // MARK: - Meal Sections

    private func mealSection(_ mealType: MealType) -> some View {
        let entries = viewModel.entriesForMeal(mealType)
        let cals = viewModel.caloriesForMeal(mealType)

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: mealType.icon)
                    .foregroundStyle(.orange)
                Text(mealType.displayName)
                    .font(.headline)
                Spacer()
                Text("\(cals) kcal")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            if entries.isEmpty {
                Text("No entries yet")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 32)
            } else {
                ForEach(entries, id: \.id) { entry in
                    foodRow(entry)
                }
            }
        }
    }

    private func foodRow(_ entry: FoodEntry) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name)
                    .font(.subheadline)
                Text(entry.servingSize)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(entry.calories) kcal")
                    .font(.subheadline.bold())
                Text("P:\(entry.proteinG.oneDecimal) C:\(entry.carbsG.oneDecimal) F:\(entry.fatG.oneDecimal)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                viewModel.deleteFoodEntry(entry, context: modelContext)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
