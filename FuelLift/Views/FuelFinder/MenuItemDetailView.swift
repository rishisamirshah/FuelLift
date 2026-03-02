import SwiftUI
import SwiftData

struct MenuItemDetailView: View {
    let item: MenuItem
    let score: MenuItemScore
    let profile: UserProfile?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var selectedMealType: MealType = .lunch
    @State private var showAddedConfirmation = false
    @State private var generatedImage: UIImage?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacingLG) {
                    // Food image
                    if let imageURL = item.imageURL {
                        AsyncImage(url: imageURL) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 200)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
                            default:
                                imagePlaceholder
                            }
                        }
                    } else if let generated = generatedImage {
                        Image(uiImage: generated)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
                    } else {
                        imagePlaceholder
                            .task {
                                if let cached = FoodImageGenerator.shared.cachedImage(for: item.name) {
                                    generatedImage = cached
                                } else {
                                    generatedImage = await FoodImageGenerator.shared.generateIfNeeded(for: item.name)
                                }
                            }
                    }

                    // Score section
                    VStack(spacing: Theme.spacingSM) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name)
                                    .font(.system(size: Theme.headlineSize, weight: .bold))
                                    .foregroundStyle(Color.appTextPrimary)

                                if item.source == .geminiEstimate {
                                    Label("AI Estimated", systemImage: "sparkles")
                                        .font(.system(size: Theme.miniSize, weight: .medium))
                                        .foregroundStyle(Color.appCarbsColor)
                                }
                            }

                            Spacer()

                            // Score badge
                            VStack(spacing: 2) {
                                ZStack {
                                    Circle()
                                        .stroke(score.label.color, lineWidth: 4)
                                        .frame(width: 56, height: 56)
                                    Text("\(score.score)")
                                        .font(.system(size: Theme.headlineSize, weight: .bold))
                                        .foregroundStyle(score.label.color)
                                }
                                Text(score.label.rawValue)
                                    .font(.system(size: Theme.miniSize, weight: .bold))
                                    .foregroundStyle(score.label.color)
                            }
                        }

                        Text(score.rationale)
                            .font(.system(size: Theme.captionSize))
                            .foregroundStyle(Color.appTextSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, Theme.spacingLG)

                    // Nutrition cards
                    VStack(spacing: Theme.spacingMD) {
                        // Calories card
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Calories")
                                    .font(.system(size: Theme.captionSize))
                                    .foregroundStyle(Color.appTextSecondary)
                                Text("\(item.calories)")
                                    .font(.system(size: Theme.titleSize, weight: .bold))
                                    .foregroundStyle(Color.appCaloriesColor)
                            }
                            Spacer()
                            Image(systemName: "flame.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(Color.appCaloriesColor)
                        }
                        .cardStyle()

                        // Macro cards row
                        HStack(spacing: Theme.spacingMD) {
                            macroCard("Protein", value: item.proteinG, color: Color.appProteinColor, icon: "p.circle.fill")
                            macroCard("Carbs", value: item.carbsG, color: Color.appCarbsColor, icon: "c.circle.fill")
                            macroCard("Fat", value: item.fatG, color: Color.appFatColor, icon: "f.circle.fill")
                        }
                    }
                    .padding(.horizontal, Theme.spacingLG)

                    // Serving size
                    if let serving = item.servingSize, !serving.isEmpty {
                        HStack {
                            Text("Serving Size")
                                .font(.system(size: Theme.captionSize))
                                .foregroundStyle(Color.appTextSecondary)
                            Spacer()
                            Text(serving)
                                .font(.system(size: Theme.bodySize, weight: .medium))
                                .foregroundStyle(Color.appTextPrimary)
                        }
                        .padding(.horizontal, Theme.spacingLG)
                    }

                    // Badges
                    if !item.badges.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Theme.spacingSM) {
                                ForEach(item.badges, id: \.self) { badge in
                                    Text(badge.capitalized)
                                        .font(.system(size: Theme.miniSize, weight: .medium))
                                        .foregroundStyle(Color.appAccent)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.appAccent.opacity(0.12))
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.horizontal, Theme.spacingLG)
                        }
                    }

                    Divider()
                        .padding(.horizontal, Theme.spacingLG)

                    // Add to Food Log
                    VStack(spacing: Theme.spacingMD) {
                        Text("Add to Food Log")
                            .font(.system(size: Theme.subheadlineSize, weight: .bold))
                            .foregroundStyle(Color.appTextPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Meal type picker
                        HStack(spacing: Theme.spacingSM) {
                            ForEach(MealType.allCases) { meal in
                                Button {
                                    selectedMealType = meal
                                } label: {
                                    VStack(spacing: 4) {
                                        Image(systemName: meal.icon)
                                            .font(.system(size: 16))
                                        Text(meal.displayName)
                                            .font(.system(size: Theme.miniSize))
                                    }
                                    .foregroundStyle(selectedMealType == meal ? .white : Color.appTextSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(selectedMealType == meal ? Color.appAccent : Color.appCardSecondary)
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSM))
                                }
                            }
                        }

                        Button {
                            addToLog()
                        } label: {
                            HStack {
                                Image(systemName: showAddedConfirmation ? "checkmark.circle.fill" : "plus.circle.fill")
                                Text(showAddedConfirmation ? "Added!" : "Add to \(selectedMealType.displayName)")
                            }
                            .primaryButtonStyle()
                        }
                        .disabled(showAddedConfirmation)
                    }
                    .padding(.horizontal, Theme.spacingLG)
                }
                .padding(.bottom, Theme.spacingHuge)
            }
            .screenBackground()
            .navigationTitle("Menu Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.appAccent)
                }
            }
        }
    }

    // MARK: - Components

    private func macroCard(_ label: String, value: Double, color: Color, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)

            Text("\(Int(value))g")
                .font(.system(size: Theme.bodySize, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)

            Text(label)
                .font(.system(size: Theme.miniSize))
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .secondaryCardStyle()
    }

    private var imagePlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.cornerRadiusLG)
                .fill(FoodCategoryMapper.backgroundColor(for: item.name))
                .frame(height: 160)
            Text(FoodCategoryMapper.emoji(for: item.name))
                .font(.system(size: 72))
        }
    }

    // MARK: - Actions

    private func addToLog() {
        let vm = FuelFinderViewModel()
        vm.addToFoodLog(item: item, mealType: selectedMealType, context: modelContext)

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showAddedConfirmation = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showAddedConfirmation = false
            dismiss()
        }
    }
}
