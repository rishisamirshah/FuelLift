import SwiftUI
import SwiftData

@MainActor
final class FuelFinderSurveyViewModel: ObservableObject {
    @Published var selectedDietType: String = ""
    @Published var selectedCuisines: Set<String> = []
    @Published var selectedProteins: Set<String> = []
    @Published var selectedAllergies: Set<String> = []

    let dietTypes = ["Omnivore", "Vegetarian", "Vegan", "Pescatarian", "Keto", "Halal", "Kosher"]

    let cuisineOptions = [
        "Indian", "Mexican", "Italian", "Chinese", "Japanese",
        "Thai", "American", "Mediterranean", "Korean", "Greek",
        "Vietnamese", "Middle Eastern"
    ]

    let proteinOptions = [
        "Chicken", "Beef", "Fish", "Tofu", "Lamb",
        "Shrimp", "Turkey", "Pork", "Paneer"
    ]

    let allergyOptions = [
        "Gluten", "Dairy", "Nuts", "Shellfish", "Soy", "Eggs"
    ]

    var shouldSkipProteins: Bool {
        selectedDietType == "Vegan"
    }

    func saveSurvey(profile: UserProfile, context: ModelContext) {
        profile.hasFuelFinderSurvey = true
        profile.fuelFinderDietType = selectedDietType
        profile.cuisinePreferencesArray = Array(selectedCuisines)
        profile.proteinPreferencesArray = shouldSkipProteins ? [] : Array(selectedProteins)
        profile.allergiesArray = Array(selectedAllergies)
        profile.updatedAt = Date()
        try? context.save()
    }

    func loadExisting(profile: UserProfile) {
        selectedDietType = profile.fuelFinderDietType
        selectedCuisines = Set(profile.cuisinePreferencesArray)
        selectedProteins = Set(profile.proteinPreferencesArray)
        selectedAllergies = Set(profile.allergiesArray)
    }
}
