import SwiftUI
import SwiftData
import CoreLocation

@MainActor
final class FuelFinderViewModel: ObservableObject {
    // MARK: - Published State

    @Published var restaurants: [Restaurant] = []
    @Published var selectedRestaurant: Restaurant?
    @Published var menuItems: [MenuItem] = []
    @Published var scoredItems: [(MenuItem, MenuItemScore)] = []
    @Published var isLoadingRestaurants = false
    @Published var isLoadingMenu = false
    @Published var searchText = ""
    @Published var selectedFilter: MenuFilter = .bestForYou
    @Published var errorMessage: String?

    enum MenuFilter: String, CaseIterable {
        case bestForYou = "Best for you"
        case allItems = "All items"
    }

    // MARK: - Dependencies

    private let locationService = LocationService.shared
    private let fuelFinderService = FuelFinderService.shared

    // MARK: - Computed

    var filteredRestaurants: [Restaurant] {
        if searchText.isEmpty { return restaurants }
        return restaurants.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var displayedItems: [(MenuItem, MenuItemScore)] {
        switch selectedFilter {
        case .bestForYou:
            return scoredItems.filter { $0.1.score >= 60 }
        case .allItems:
            return scoredItems
        }
    }

    var hasGeminiItems: Bool {
        menuItems.contains { $0.source == .geminiEstimate }
    }

    // MARK: - Actions

    func loadRestaurants() async {
        guard let location = locationService.currentLocation else {
            locationService.requestLocation()
            return
        }

        isLoadingRestaurants = true
        errorMessage = nil

        do {
            restaurants = try await fuelFinderService.fetchNearbyRestaurants(
                coordinate: location.coordinate
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingRestaurants = false
    }

    func selectRestaurant(_ restaurant: Restaurant, profile: UserProfile?) {
        selectedRestaurant = restaurant
        Task {
            await loadMenu(for: restaurant, profile: profile)
        }
    }

    func loadMenu(for restaurant: Restaurant, profile: UserProfile?) async {
        isLoadingMenu = true
        menuItems = []
        scoredItems = []
        errorMessage = nil

        do {
            let items = try await fuelFinderService.fetchMenuItems(for: restaurant)
            menuItems = items

            if let profile {
                scoredItems = fuelFinderService.scoreAndSort(items: items, profile: profile)
            } else {
                // No profile — show items unsorted with neutral scores
                scoredItems = items.map { ($0, MenuItemScore(score: 50, label: .fair, rationale: "Set up your profile for personalized scores")) }
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingMenu = false
    }

    func addToFoodLog(item: MenuItem, mealType: MealType, context: ModelContext) {
        let entry = FoodEntry(
            name: item.name,
            calories: item.calories,
            proteinG: item.proteinG,
            carbsG: item.carbsG,
            fatG: item.fatG,
            servingSize: item.servingSize ?? "",
            mealType: mealType.rawValue,
            date: Date(),
            source: "restaurant"
        )
        context.insert(entry)
        try? context.save()
    }
}
