import SwiftUI
import MapKit
import SwiftData

struct FuelFinderMapView: View {
    @ObservedObject var viewModel: FuelFinderViewModel
    let profile: UserProfile?
    @State private var selectedRestaurant: Restaurant?
    @State private var navigateToDetail = false

    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $viewModel.mapCameraPosition, selection: $selectedRestaurant) {
                // User location
                UserAnnotation()

                // Restaurant pins
                ForEach(viewModel.restaurants) { restaurant in
                    Annotation(restaurant.name, coordinate: restaurant.coordinate, anchor: .bottom) {
                        restaurantPin(restaurant)
                    }
                    .tag(restaurant)
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .onMapCameraChange(frequency: .onEnd) { context in
                viewModel.onMapCameraChange(center: context.region.center)
            }
            .onChange(of: selectedRestaurant) { _, newValue in
                if newValue != nil {
                    navigateToDetail = true
                }
            }

            // Search This Area button
            if viewModel.showSearchThisArea {
                VStack {
                    Button {
                        Task { await viewModel.searchThisArea() }
                    } label: {
                        HStack(spacing: Theme.spacingSM) {
                            if viewModel.isLoadingRestaurants {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.8)
                            }
                            Text("Search This Area")
                                .font(.system(size: Theme.captionSize, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, Theme.spacingLG)
                        .padding(.vertical, Theme.spacingSM)
                        .background(Color.appAccent)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                    }
                    .padding(.top, Theme.spacingSM)
                    .disabled(viewModel.isLoadingRestaurants)

                    Spacer()
                }
            }
        }
        .navigationDestination(isPresented: $navigateToDetail) {
            if let restaurant = selectedRestaurant {
                RestaurantDetailView(
                    restaurant: restaurant,
                    viewModel: viewModel,
                    profile: profile
                )
            }
        }
        .onAppear {
            viewModel.initializeMapPosition()
        }
    }

    // MARK: - Restaurant Pin

    private func restaurantPin(_ restaurant: Restaurant) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 2) {
                Text(restaurant.name)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)

                if let rating = restaurant.rating {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(Color.appCarbsColor)
                        Text(String(format: "%.1f", rating))
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(restaurant.isOpen == true ? Color.appAccent : Color.appFatColor, lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)

            // Pin arrow
            Image(systemName: "triangle.fill")
                .font(.system(size: 8))
                .foregroundStyle(restaurant.isOpen == true ? Color.appAccent : Color.appFatColor)
                .rotationEffect(.degrees(180))
                .offset(y: -2)
        }
    }
}
