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
            VStack(spacing: 0) {
                // View mode picker + reset button
                if profile?.hasFuelFinderSurvey == true {
                    HStack {
                        Picker("View", selection: $viewModel.viewMode) {
                            ForEach(FuelFinderViewModel.ViewMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)

                        Button {
                            viewModel.showResetAlert = true
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.appTextSecondary)
                                .padding(8)
                                .background(Color.appCardSecondary)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, Theme.spacingLG)
                    .padding(.vertical, Theme.spacingSM)
                } else {
                    // No survey yet — just show mode picker
                    Picker("View", selection: $viewModel.viewMode) {
                        ForEach(FuelFinderViewModel.ViewMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, Theme.spacingLG)
                    .padding(.vertical, Theme.spacingSM)
                }

                // Cuisine / mood filter pills
                cuisineFilterPills

                // Content
                if viewModel.viewMode == .list {
                    listContent
                } else {
                    FuelFinderMapView(viewModel: viewModel, profile: profile)
                }
            }
            .screenBackground()
            .navigationTitle("FuelFinder")
            .searchable(text: $viewModel.searchText, prompt: "Search restaurants...")
            .onChange(of: viewModel.searchText) { _, _ in
                viewModel.searchRestaurants()
            }
            .onAppear {
                viewModel.currentProfile = profile
                viewModel.checkSurvey(profile: profile)
                if locationService.currentLocation != nil && viewModel.restaurants.isEmpty {
                    Task { await viewModel.loadRestaurants(profile: profile) }
                }
            }
            .onChange(of: locationService.currentLocation) { _, newLocation in
                if newLocation != nil && viewModel.restaurants.isEmpty {
                    Task { await viewModel.loadRestaurants(profile: profile) }
                }
            }
            .refreshable {
                await viewModel.loadRestaurants(profile: profile)
            }
            .fullScreenCover(isPresented: $viewModel.showSurvey) {
                FuelFinderSurveyView()
            }
            .alert("Reset Preferences", isPresented: $viewModel.showResetAlert) {
                Button("Reset", role: .destructive) {
                    viewModel.resetSurvey(profile: profile, context: modelContext)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will reset your dietary preferences and show the survey again next time you open FuelFinder.")
            }
        }
    }

    // MARK: - List Content

    private var listContent: some View {
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
            ForEach(0..<6, id: \.self) { _ in
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
                Task { await viewModel.loadRestaurants(profile: profile) }
            } label: {
                Text("Try Again")
                    .primaryButtonStyle()
            }
        }
        .padding(.vertical, Theme.spacingXXL)
        .cardStyle()
    }

    // MARK: - Cuisine Filter Pills

    private var cuisineFilterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.spacingSM) {
                ForEach(FuelFinderViewModel.CuisineFilter.allCases, id: \.self) { filter in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            viewModel.selectedCuisineFilter = filter
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: filter.icon)
                                .font(.system(size: 11))
                            Text(filter.rawValue)
                                .font(.system(size: Theme.captionSize, weight: .semibold))
                        }
                        .foregroundStyle(viewModel.selectedCuisineFilter == filter ? .white : Color.appTextSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(viewModel.selectedCuisineFilter == filter ? Color.appAccent : Color.appCardSecondary)
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, Theme.spacingLG)
            .padding(.vertical, Theme.spacingXS)
        }
    }

    // MARK: - Restaurant List

    private var restaurantList: some View {
        LazyVStack(spacing: Theme.spacingMD) {
            let displayed = viewModel.filteredRestaurants
            if displayed.isEmpty && viewModel.selectedCuisineFilter != .all {
                VStack(spacing: Theme.spacingSM) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.appTextTertiary)
                    Text("No \(viewModel.selectedCuisineFilter.rawValue) restaurants found nearby")
                        .font(.system(size: Theme.bodySize))
                        .foregroundStyle(Color.appTextSecondary)
                    Button {
                        viewModel.selectedCuisineFilter = .all
                    } label: {
                        Text("Show All")
                            .font(.system(size: Theme.captionSize, weight: .semibold))
                            .foregroundStyle(Color.appAccent)
                    }
                }
                .padding(.vertical, Theme.spacingXXL)
            } else {
                ForEach(displayed) { restaurant in
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
}
