import SwiftUI
import SwiftData
import CoreLocation
import MapKit
import Combine

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
    @Published var viewMode: ViewMode = .list
    @Published var showSurvey = false
    @Published var showResetAlert = false

    // Map state
    @Published var mapCameraPosition: MapCameraPosition = .automatic
    @Published var mapCenter: CLLocationCoordinate2D?
    @Published var showSearchThisArea = false

    enum MenuFilter: String, CaseIterable {
        case bestForYou = "Best for you"
        case allItems = "All items"
    }

    enum ViewMode: String, CaseIterable {
        case list = "List"
        case map = "Map"
    }

    // MARK: - Dependencies

    private let locationService = LocationService.shared
    private let fuelFinderService = FuelFinderService.shared
    private var searchTask: Task<Void, Never>?

    // MARK: - Computed

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

    func searchRestaurants() {
        searchTask?.cancel()

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        if query.isEmpty {
            // Reset to nearby
            searchTask = Task {
                await loadRestaurants()
            }
            return
        }

        // Debounce 500ms
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }

            guard let location = locationService.currentLocation else { return }

            isLoadingRestaurants = true
            errorMessage = nil

            do {
                restaurants = try await fuelFinderService.searchRestaurants(
                    query: query,
                    coordinate: location.coordinate
                )
            } catch {
                if !Task.isCancelled {
                    errorMessage = error.localizedDescription
                }
            }

            if !Task.isCancelled {
                isLoadingRestaurants = false
            }
        }
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
            let items = try await fuelFinderService.fetchMenuItems(for: restaurant, profile: profile)
            menuItems = items

            if let profile {
                scoredItems = fuelFinderService.scoreAndSort(items: items, profile: profile)
            } else {
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

    // MARK: - Survey

    func checkSurvey(profile: UserProfile?) {
        if let profile, !profile.hasFuelFinderSurvey {
            showSurvey = true
        }
    }

    func resetSurvey(profile: UserProfile?, context: ModelContext) {
        guard let profile else { return }
        profile.hasFuelFinderSurvey = false
        profile.fuelFinderDietType = ""
        profile.fuelFinderCuisinePreferences = "[]"
        profile.fuelFinderProteinPreferences = "[]"
        profile.fuelFinderAllergies = "[]"
        profile.updatedAt = Date()
        try? context.save()
    }

    // MARK: - Map

    func searchThisArea() async {
        guard let center = mapCenter else { return }

        isLoadingRestaurants = true
        errorMessage = nil
        showSearchThisArea = false

        do {
            restaurants = try await fuelFinderService.fetchNearbyRestaurants(coordinate: center)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingRestaurants = false
    }

    func onMapCameraChange(center: CLLocationCoordinate2D) {
        // Show "Search This Area" if user moved significantly from last search center
        if let current = mapCenter {
            let distance = CLLocation(latitude: center.latitude, longitude: center.longitude)
                .distance(from: CLLocation(latitude: current.latitude, longitude: current.longitude))
            if distance > 500 { // More than 500m moved
                showSearchThisArea = true
            }
        }
        mapCenter = center
    }

    func initializeMapPosition() {
        if let location = locationService.currentLocation {
            mapCameraPosition = .region(MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 5000,
                longitudinalMeters: 5000
            ))
            mapCenter = location.coordinate
        }
    }
}
