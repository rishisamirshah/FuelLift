import SwiftUI
import SwiftData

struct FuelFinderSurveyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = FuelFinderSurveyViewModel()
    @Query private var profiles: [UserProfile]
    @State private var step = 0

    private var profile: UserProfile? { profiles.first }

    private var totalSteps: Int {
        viewModel.shouldSkipProteins ? 3 : 4
    }

    private var adjustedStep: Int {
        // If vegan and past step 2, skip proteins (step 2) and go to allergies
        if viewModel.shouldSkipProteins && step >= 2 {
            return step + 1
        }
        return step
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress capsules
                HStack(spacing: Theme.spacingSM) {
                    ForEach(0..<totalSteps, id: \.self) { i in
                        Capsule()
                            .fill(i <= step ? Color.appAccent : Color.appCardSecondary)
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, Theme.spacingXXL)
                .padding(.top, Theme.spacingLG)

                TabView(selection: $step) {
                    dietTypeStep.tag(0)
                    cuisineStep.tag(1)
                    if !viewModel.shouldSkipProteins {
                        proteinStep.tag(2)
                        allergyStep.tag(3)
                    } else {
                        allergyStep.tag(2)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Navigation buttons
                navigationButtons
                    .padding(.horizontal, Theme.spacingXXL)
                    .padding(.bottom, Theme.spacingXXL)
            }
            .screenBackground()
            .navigationTitle("Nutrition Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Skip") { dismiss() }
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
    }

    // MARK: - Step 1: Diet Type

    private var dietTypeStep: some View {
        stepContent(
            title: "What's Your Diet?",
            subtitle: "This helps us find the best restaurants for you."
        ) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.spacingMD) {
                ForEach(viewModel.dietTypes, id: \.self) { diet in
                    optionCard(
                        text: diet,
                        icon: dietIcon(diet),
                        isSelected: viewModel.selectedDietType == diet
                    ) {
                        viewModel.selectedDietType = diet
                    }
                }
            }
        }
    }

    // MARK: - Step 2: Cuisines

    private var cuisineStep: some View {
        stepContent(
            title: "Favorite Cuisines",
            subtitle: "Select all the cuisines you enjoy."
        ) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.spacingMD) {
                ForEach(viewModel.cuisineOptions, id: \.self) { cuisine in
                    optionCard(
                        text: cuisine,
                        icon: cuisineIcon(cuisine),
                        isSelected: viewModel.selectedCuisines.contains(cuisine)
                    ) {
                        toggleSelection(cuisine, in: &viewModel.selectedCuisines)
                    }
                }
            }
        }
    }

    // MARK: - Step 3: Proteins

    private var proteinStep: some View {
        stepContent(
            title: "Preferred Proteins",
            subtitle: "What proteins do you enjoy eating?"
        ) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.spacingMD) {
                ForEach(viewModel.proteinOptions, id: \.self) { protein in
                    optionCard(
                        text: protein,
                        icon: proteinIcon(protein),
                        isSelected: viewModel.selectedProteins.contains(protein)
                    ) {
                        toggleSelection(protein, in: &viewModel.selectedProteins)
                    }
                }
            }
        }
    }

    // MARK: - Step 4: Allergies

    private var allergyStep: some View {
        stepContent(
            title: "Any Allergies?",
            subtitle: "We'll make sure to flag these items."
        ) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.spacingMD) {
                ForEach(viewModel.allergyOptions, id: \.self) { allergy in
                    optionCard(
                        text: allergy,
                        icon: "exclamationmark.triangle",
                        isSelected: viewModel.selectedAllergies.contains(allergy)
                    ) {
                        toggleSelection(allergy, in: &viewModel.selectedAllergies)
                    }
                }

                optionCard(
                    text: "None",
                    icon: "checkmark.shield",
                    isSelected: viewModel.selectedAllergies.isEmpty
                ) {
                    viewModel.selectedAllergies.removeAll()
                }
            }
        }
    }

    // MARK: - Shared Components

    private func stepContent<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ScrollView {
            VStack(spacing: Theme.spacingXL) {
                VStack(spacing: Theme.spacingSM) {
                    Text(title)
                        .font(.system(size: Theme.headlineSize, weight: .bold))
                        .foregroundStyle(Color.appTextPrimary)

                    Text(subtitle)
                        .font(.system(size: Theme.bodySize))
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, Theme.spacingXL)

                content()
                    .padding(.horizontal, Theme.spacingLG)
            }
            .padding(.bottom, Theme.spacingHuge)
        }
    }

    private func optionCard(text: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: Theme.spacingSM) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? Color.appAccent : Color.appTextSecondary)

                Text(text)
                    .font(.system(size: Theme.captionSize, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.appTextPrimary : Color.appTextSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.spacingMD)
            .background(isSelected ? Color.appAccent.opacity(0.15) : Color.appCardSecondary)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusMD)
                    .stroke(isSelected ? Color.appAccent : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var navigationButtons: some View {
        HStack(spacing: Theme.spacingMD) {
            if step > 0 {
                Button {
                    withAnimation { step -= 1 }
                } label: {
                    Text("Back")
                        .font(.system(size: Theme.bodySize, weight: .semibold))
                        .foregroundStyle(Color.appTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.appCardSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                }
            }

            Button {
                if step < totalSteps - 1 {
                    withAnimation { step += 1 }
                } else {
                    // Done
                    if let profile {
                        viewModel.saveSurvey(profile: profile, context: modelContext)
                    }
                    dismiss()
                }
            } label: {
                Text(step < totalSteps - 1 ? "Next" : "Done")
                    .primaryButtonStyle()
            }
            .disabled(step == 0 && viewModel.selectedDietType.isEmpty)
        }
    }

    // MARK: - Helpers

    private func toggleSelection(_ item: String, in set: inout Set<String>) {
        if set.contains(item) {
            set.remove(item)
        } else {
            set.insert(item)
        }
    }

    private func dietIcon(_ diet: String) -> String {
        switch diet {
        case "Omnivore": return "fork.knife"
        case "Vegetarian": return "leaf"
        case "Vegan": return "leaf.fill"
        case "Pescatarian": return "fish"
        case "Keto": return "flame"
        case "Halal": return "moon.stars"
        case "Kosher": return "star.of.david"
        default: return "fork.knife"
        }
    }

    private func cuisineIcon(_ cuisine: String) -> String {
        switch cuisine {
        case "Indian": return "flame.fill"
        case "Mexican": return "sun.max"
        case "Italian": return "leaf.fill"
        case "Chinese": return "wok.fill"
        case "Japanese": return "fish"
        case "Thai": return "tropicalstorm"
        case "American": return "star.fill"
        case "Mediterranean": return "sun.haze"
        case "Korean": return "flame"
        case "Greek": return "building.columns"
        case "Vietnamese": return "leaf"
        case "Middle Eastern": return "moon.stars.fill"
        default: return "fork.knife"
        }
    }

    private func proteinIcon(_ protein: String) -> String {
        switch protein {
        case "Chicken": return "bird"
        case "Beef": return "fork.knife"
        case "Fish": return "fish"
        case "Tofu": return "square.fill"
        case "Lamb": return "fork.knife"
        case "Shrimp": return "fish.fill"
        case "Turkey": return "bird.fill"
        case "Pork": return "fork.knife"
        case "Paneer": return "square.grid.2x2"
        default: return "fork.knife"
        }
    }
}
