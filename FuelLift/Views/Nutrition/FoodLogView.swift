import SwiftUI
import SwiftData

struct FoodLogView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = NutritionViewModel()
    @State private var showAddSheet = false
    @State private var showCamera = false
    @State private var showBarcode = false
    @State private var showDescriptionSheet = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: Theme.spacingXXL) {
                        // Date picker
                        DatePicker("Date", selection: $viewModel.selectedDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .tint(Color.appAccent)
                            .padding(.horizontal, Theme.spacingLG)
                            .onChange(of: viewModel.selectedDate) { _, _ in
                                viewModel.loadEntries(context: modelContext)
                            }

                        // Daily summary card
                        dailySummaryCard
                            .padding(.horizontal, Theme.spacingLG)
                            .animation(.easeInOut(duration: 0.3), value: viewModel.totalCalories)

                        // Water tracker
                        waterCard
                            .padding(.horizontal, Theme.spacingLG)

                        // Meals
                        ForEach(MealType.allCases) { mealType in
                            mealSection(mealType)
                                .padding(.horizontal, Theme.spacingLG)
                                .animation(.easeInOut(duration: 0.3), value: viewModel.todayEntries.count)
                        }
                    }
                    .padding(.vertical, Theme.spacingLG)
                }
                .screenBackground()

                // FAB
                FloatingActionButton {
                    showCamera = true
                }
                .padding(Theme.spacingXL)
            }
            .navigationTitle("Nutrition")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button { showCamera = true } label: {
                            Label {
                                Text("Scan Food Photo")
                            } icon: {
                                Image("icon_camera").resizable().renderingMode(.original).frame(width: 20, height: 20)
                            }
                        }
                        Button { showBarcode = true } label: {
                            Label {
                                Text("Scan Barcode")
                            } icon: {
                                Image("icon_barcode").resizable().renderingMode(.original).frame(width: 20, height: 20)
                            }
                        }
                        Button { showDescriptionSheet = true } label: {
                            Label {
                                Text("Describe Food")
                            } icon: {
                                Image("icon_text_bubble").resizable().renderingMode(.original).frame(width: 20, height: 20)
                            }
                        }
                        Button { showAddSheet = true } label: {
                            Label {
                                Text("Manual Entry")
                            } icon: {
                                Image("icon_pencil").resizable().renderingMode(.original).frame(width: 20, height: 20)
                            }
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color.appAccent)
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
            .sheet(isPresented: $showDescriptionSheet) {
                FoodDescriptionView(nutritionViewModel: viewModel)
            }
            .onAppear {
                viewModel.loadEntries(context: modelContext)
            }
        }
    }

    // MARK: - Daily Summary

    private var dailySummaryCard: some View {
        VStack(spacing: Theme.spacingLG) {
            // Calorie header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(viewModel.totalCalories)")
                        .font(.system(size: Theme.titleSize, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)
                        .contentTransition(.numericText())
                        .animation(.snappy, value: viewModel.totalCalories)
                    Text("calories eaten")
                        .font(.system(size: Theme.captionSize, weight: .medium))
                        .foregroundStyle(Color.appTextSecondary)
                }
                Spacer()
            }

            // Macro pills
            HStack(spacing: Theme.spacingMD) {
                macroPill("Protein", value: viewModel.totalProtein, color: Color.appProteinColor)
                macroPill("Carbs", value: viewModel.totalCarbs, color: Color.appCarbsColor)
                macroPill("Fat", value: viewModel.totalFat, color: Color.appFatColor)
            }
        }
        .cardStyle()
    }

    private func macroPill(_ label: String, value: Double, color: Color) -> some View {
        VStack(spacing: Theme.spacingXS) {
            Text(value.oneDecimal + "g")
                .font(.system(size: Theme.bodySize, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: Theme.miniSize, weight: .medium))
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingSM)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSM))
    }

    // MARK: - Water Card

    private var waterCard: some View {
        HStack(spacing: Theme.spacingMD) {
            Image("icon_water_drop").resizable().renderingMode(.original)
                .frame(width: 20, height: 20)

            Text("\(viewModel.totalWaterML) mL")
                .font(.system(size: Theme.subheadlineSize, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)

            Spacer()

            ForEach([250, 500], id: \.self) { amount in
                Button {
                    viewModel.addWater(amountML: amount, context: modelContext)
                } label: {
                    Text("+\(amount)")
                        .font(.system(size: Theme.captionSize, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.appWaterColor)
                        .padding(.horizontal, Theme.spacingMD)
                        .padding(.vertical, Theme.spacingXS)
                        .background(Color.appWaterColor.opacity(0.15))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .cardStyle()
    }

    // MARK: - Meal Sections

    private func mealSection(_ mealType: MealType) -> some View {
        let entries = viewModel.entriesForMeal(mealType)
        let cals = viewModel.caloriesForMeal(mealType)

        return VStack(alignment: .leading, spacing: Theme.spacingSM) {
            // Meal header
            HStack {
                Image(systemName: mealType.icon)
                    .foregroundStyle(Color.appAccent)
                Text(mealType.displayName)
                    .font(.system(size: Theme.subheadlineSize, weight: .bold))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Text("\(cals) kcal")
                    .font(.system(size: Theme.bodySize, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.appTextSecondary)
            }

            if entries.isEmpty {
                Text("No entries yet")
                    .font(.system(size: Theme.captionSize))
                    .foregroundStyle(Color.appTextTertiary)
                    .padding(.leading, Theme.spacingXL)
            } else {
                VStack(spacing: 0) {
                    ForEach(entries, id: \.id) { entry in
                        foodRow(entry)

                        if entry.id != entries.last?.id {
                            Divider()
                                .background(Color.appCardSecondary)
                        }
                    }
                }
                .background(Color.appCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
            }
        }
    }

    private func foodRow(_ entry: FoodEntry) -> some View {
        NavigationLink {
            FoodEntryDetailView(entry: entry)
        } label: {
            HStack(spacing: Theme.spacingMD) {
                // Thumbnail
                if let imageData = entry.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSM))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.name)
                        .lineLimit(1)
                        .font(.system(size: Theme.bodySize, weight: .medium))
                        .foregroundStyle(Color.appTextPrimary)
                    HStack(spacing: Theme.spacingSM) {
                        Text("\(entry.calories) kcal")
                            .font(.system(size: Theme.captionSize, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.appTextPrimary)
                        Text("P:\(entry.proteinG.oneDecimal) C:\(entry.carbsG.oneDecimal) F:\(entry.fatG.oneDecimal)")
                            .font(.system(size: Theme.miniSize))
                            .foregroundStyle(Color.appTextTertiary)
                    }
                }
                Spacer()
                Text(entry.date.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: Theme.miniSize))
                    .foregroundStyle(Color.appTextTertiary)
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, Theme.spacingLG)
        .padding(.vertical, Theme.spacingSM)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                viewModel.deleteFoodEntry(entry, context: modelContext)
            } label: {
                Label {
                    Text("Delete")
                } icon: {
                    Image("icon_trash").resizable().renderingMode(.original).frame(width: 20, height: 20)
                }
            }
        }
    }
}
