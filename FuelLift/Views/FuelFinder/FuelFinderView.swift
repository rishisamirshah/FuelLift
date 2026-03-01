import SwiftUI
import SwiftData
import Shimmer

struct FuelFinderView: View {
    @StateObject private var viewModel = FuelFinderViewModel()
    @ObservedObject private var locationService = LocationService.shared
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacingLG) {
                    if locationService.authorizationStatus == .notDetermined ||
                       locationService.authorizationStatus == .denied ||
                       locationService.authorizationStatus == .restricted {
                        locationPromptCard
                    } else if viewModel.isLoadingRestaurants {
                        shimmerCards
                    } else if let error = viewModel.errorMessage, viewModel.restaurants.isEmpty {
                        errorCard(error)
                    } else {
                        restaurantList
                    }
                }
                .padding(.horizontal, Theme.spacingLG)
                .padding(.bottom, Theme.spacingHuge)
            }
            .screenBackground()
            .navigationTitle("FuelFinder")
            .searchable(text: $viewModel.searchText, prompt: "Search restaurants...")
            .onAppear {
                if locationService.currentLocation != nil && viewModel.restaurants.isEmpty {
                    Task { await viewModel.loadRestaurants() }
                }
            }
            .onChange(of: locationService.currentLocation) { _, newLocation in
                if newLocation != nil && viewModel.restaurants.isEmpty {
                    Task { await viewModel.loadRestaurants() }
                }
            }
            .refreshable {
                await viewModel.loadRestaurants()
            }
        }
    }

    // MARK: - Location Prompt

    private var locationPromptCard: some View {
        VStack(spacing: Theme.spacingLG) {
            Image(systemName: "location.slash.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.appAccent)

            Text("Enable Location")
                .font(.system(size: Theme.headlineSize, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)

            Text("FuelFinder needs your location to discover healthy meals at nearby restaurants.")
                .font(.system(size: Theme.bodySize))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)

            Button {
                locationService.requestLocation()
            } label: {
                Text("Allow Location Access")
                    .primaryButtonStyle()
            }
        }
        .padding(.vertical, Theme.spacingHuge)
        .cardStyle()
    }

    // MARK: - Shimmer Loading

    private var shimmerCards: some View {
        VStack(spacing: Theme.spacingMD) {
            ForEach(0..<4, id: \.self) { _ in
                RoundedRectangle(cornerRadius: Theme.cornerRadiusLG)
                    .fill(Color.appCardBackground)
                    .frame(height: 120)
                    .shimmering()
            }
        }
    }

    // MARK: - Error

    private func errorCard(_ message: String) -> some View {
        VStack(spacing: Theme.spacingMD) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 36))
                .foregroundStyle(Color.appCarbsColor)

            Text(message)
                .font(.system(size: Theme.bodySize))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)

            Button {
                Task { await viewModel.loadRestaurants() }
            } label: {
                Text("Try Again")
                    .primaryButtonStyle()
            }
        }
        .padding(.vertical, Theme.spacingXXL)
        .cardStyle()
    }

    // MARK: - Restaurant List

    private var restaurantList: some View {
        LazyVStack(spacing: Theme.spacingMD) {
            ForEach(viewModel.filteredRestaurants) { restaurant in
                NavigationLink {
                    RestaurantDetailView(
                        restaurant: restaurant,
                        viewModel: viewModel,
                        profile: profile
                    )
                } label: {
                    RestaurantCard(restaurant: restaurant)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
