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
    @Published var selectedCuisineFilter: CuisineFilter = .all

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

    // MARK: - Cuisine / Mood Filters

    enum CuisineFilter: String, CaseIterable {
        case all = "All"
        case healthy = "Healthy"
        case comfort = "Comfort"
        case quickBite = "Quick Bite"
        case indian = "Indian"
        case mexican = "Mexican"
        case italian = "Italian"
        case chinese = "Chinese"
        case japanese = "Japanese"
        case thai = "Thai"
        case mediterranean = "Mediterranean"
        case korean = "Korean"
        case american = "American"
        case seafood = "Seafood"
        case vegan = "Vegan"

        var icon: String {
            switch self {
            case .all: return "fork.knife"
            case .healthy: return "leaf.fill"
            case .comfort: return "heart.fill"
            case .quickBite: return "bolt.fill"
            case .indian: return "flame.fill"
            case .mexican: return "sun.max.fill"
            case .italian: return "wineglass.fill"
            case .chinese: return "takeoutbag.and.cup.and.straw.fill"
            case .japanese: return "fish.fill"
            case .thai: return "leaf.arrow.circlepath"
            case .mediterranean: return "sun.and.horizon.fill"
            case .korean: return "frying.pan.fill"
            case .american: return "star.fill"
            case .seafood: return "fish.fill"
            case .vegan: return "carrot.fill"
            }
        }

        /// Google Places types and name keywords to match
        var matchTerms: [String] {
            switch self {
            case .all: return []
            case .healthy: return ["salad", "health", "organic", "juice", "smoothie", "poke", "acai", "vegan", "vegetarian", "fit", "fresh", "green", "bowl"]
            case .comfort: return ["burger", "pizza", "bbq", "barbecue", "diner", "grill", "wings", "mac", "fried", "comfort", "soul", "home"]
            case .quickBite: return ["fast_food", "sandwich", "cafe", "coffee", "bakery", "deli", "sub", "wrap", "bagel", "quick"]
            case .indian: return ["indian", "curry", "tandoori", "masala", "biryani", "dosa", "naan", "tikka", "punjabi", "south_asian"]
            case .mexican: return ["mexican", "taco", "burrito", "taqueria", "cantina", "salsa", "enchilada", "quesadilla", "tex-mex", "latin"]
            case .italian: return ["italian", "pizza", "pasta", "trattoria", "ristorante", "gelato", "osteria", "panini", "calzone"]
            case .chinese: return ["chinese", "dim_sum", "wok", "dumpling", "szechuan", "hunan", "cantonese", "noodle", "peking"]
            case .japanese: return ["japanese", "sushi", "ramen", "teriyaki", "tempura", "izakaya", "udon", "sashimi", "bento", "hibachi"]
            case .thai: return ["thai", "pad_thai", "curry", "tom_yum", "bangkok", "basil", "satay"]
            case .mediterranean: return ["mediterranean", "greek", "falafel", "shawarma", "hummus", "kebab", "gyro", "pita", "lebanese", "turkish", "middle_eastern"]
            case .korean: return ["korean", "bbq", "bibimbap", "bulgogi", "kimchi", "kbbq", "galbi", "boba"]
            case .american: return ["american", "burger", "steak", "steakhouse", "diner", "grill", "bbq", "wings", "bar_and_grill"]
            case .seafood: return ["seafood", "fish", "sushi", "lobster", "crab", "shrimp", "oyster", "poke", "clam"]
            case .vegan: return ["vegan", "vegetarian", "plant", "organic", "raw", "health_food"]
            }
        }
    }

    // MARK: - Dependencies

    private let locationService = LocationService.shared
    private let fuelFinderService = FuelFinderService.shared
    private var searchTask: Task<Void, Never>?

    /// Weak reference to current profile for search ranking
    var currentProfile: UserProfile?

    // MARK: - Computed

    var filteredRestaurants: [Restaurant] {
        guard selectedCuisineFilter != .all else { return restaurants }

        let terms = selectedCuisineFilter.matchTerms
        return restaurants.filter { restaurant in
            let nameLower = restaurant.name.lowercased()
            let typesLower = restaurant.types.map { $0.lowercased() }
            let allText = nameLower + " " + typesLower.joined(separator: " ")

            return terms.contains { term in
                allText.contains(term)
            }
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

    func loadRestaurants(profile: UserProfile? = nil) async {
        guard let location = locationService.currentLocation else {
            locationService.requestLocation()
            return
        }

        isLoadingRestaurants = true
        errorMessage = nil

        do {
            var results = try await fuelFinderService.fetchNearbyRestaurants(
                coordinate: location.coordinate
            )

            // AI-rank restaurants based on user's fitness profile
            results = await fuelFinderService.aiRankRestaurants(results, profile: profile)

            restaurants = results
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
                var results = try await fuelFinderService.searchRestaurants(
                    query: query,
                    coordinate: location.coordinate
                )

                // AI-rank search results too
                results = await fuelFinderService.aiRankRestaurants(results, profile: currentProfile)

                if !Task.isCancelled {
                    restaurants = results
                }
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

        // Immediately re-show survey
        showSurvey = true
    }

    // MARK: - Map

    func searchThisArea() async {
        guard let center = mapCenter else { return }

        isLoadingRestaurants = true
        errorMessage = nil
        showSearchThisArea = false

        do {
            var results = try await fuelFinderService.fetchNearbyRestaurants(coordinate: center)
            results = await fuelFinderService.aiRankRestaurants(results, profile: currentProfile)
            restaurants = results
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
