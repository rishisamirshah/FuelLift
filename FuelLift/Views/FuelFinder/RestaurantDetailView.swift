import SwiftUI
import SwiftData
import MapKit
import Shimmer

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @ObservedObject var viewModel: FuelFinderViewModel
    let profile: UserProfile?
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                mapSection
                filterSection
                menuSection
            }
            .padding(.bottom, Theme.spacingHuge)
        }
        .screenBackground()
        .navigationTitle(restaurant.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.selectedRestaurant?.id != restaurant.id {
                viewModel.selectRestaurant(restaurant, profile: profile)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: Theme.spacingMD) {
            // Photo
            if let photoRef = restaurant.photoReference,
               let photoURL = GooglePlacesService.shared.photoURL(reference: photoRef, maxWidth: 800) {
                AsyncImage(url: photoURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                    default:
                        Rectangle()
                            .fill(Color.appCardSecondary)
                            .frame(height: 200)
                            .shimmering()
                    }
                }
            }

            VStack(alignment: .leading, spacing: Theme.spacingSM) {
                HStack {
                    Text(restaurant.name)
                        .font(.system(size: Theme.headlineSize, weight: .bold))
                        .foregroundStyle(Color.appTextPrimary)

                    Spacer()

                    if let isOpen = restaurant.isOpen {
                        Text(isOpen ? "Open" : "Closed")
                            .font(.system(size: Theme.captionSize, weight: .semibold))
                            .foregroundStyle(isOpen ? .green : Color.appFatColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background((isOpen ? Color.green : Color.appFatColor).opacity(0.15))
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: Theme.spacingSM) {
                    if let rating = restaurant.rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(Color.appCarbsColor)
                            Text(String(format: "%.1f", rating))
                                .fontWeight(.medium)
                        }
                        .font(.system(size: Theme.bodySize))
                    }

                    if let count = restaurant.userRatingsTotal {
                        Text("(\(count))")
                            .font(.system(size: Theme.captionSize))
                            .foregroundStyle(Color.appTextSecondary)
                    }

                    if let price = restaurant.priceLevelText {
                        Text(price)
                            .font(.system(size: Theme.bodySize))
                            .foregroundStyle(Color.appTextSecondary)
                    }

                    if let distance = restaurant.distanceText {
                        Text(distance)
                            .font(.system(size: Theme.bodySize))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }

                if !restaurant.address.isEmpty {
                    Text(restaurant.address)
                        .font(.system(size: Theme.captionSize))
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .padding(.horizontal, Theme.spacingLG)
        }
    }

    // MARK: - Map

    private var mapSection: some View {
        VStack(spacing: Theme.spacingSM) {
            Map {
                Marker(restaurant.name, coordinate: restaurant.coordinate)
                    .tint(Color.appAccent)
            }
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
            .allowsHitTesting(false)

            Button {
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: restaurant.coordinate))
                mapItem.name = restaurant.name
                mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
            } label: {
                Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                    .font(.system(size: Theme.captionSize, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
            }
        }
        .padding(.horizontal, Theme.spacingLG)
        .padding(.vertical, Theme.spacingMD)
    }

    // MARK: - Filter

    private var filterSection: some View {
        VStack(spacing: Theme.spacingSM) {
            // Filter pills
            HStack(spacing: Theme.spacingSM) {
                ForEach(FuelFinderViewModel.MenuFilter.allCases, id: \.self) { filter in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            viewModel.selectedFilter = filter
                        }
                    } label: {
                        Text(filter.rawValue)
                            .font(.system(size: Theme.captionSize, weight: .semibold))
                            .foregroundStyle(viewModel.selectedFilter == filter ? .white : Color.appTextSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(viewModel.selectedFilter == filter ? Color.appAccent : Color.appCardSecondary)
                            .clipShape(Capsule())
                    }
                }
                Spacer()
            }
            .padding(.horizontal, Theme.spacingLG)

            // Gemini disclaimer
            if viewModel.hasGeminiItems {
                HStack(spacing: Theme.spacingXS) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10))
                    Text("AI Estimated — nutrition values are approximate")
                        .font(.system(size: Theme.miniSize))
                }
                .foregroundStyle(Color.appCarbsColor)
                .padding(.horizontal, Theme.spacingLG)
            }
        }
    }

    // MARK: - Menu

    private var menuSection: some View {
        VStack(spacing: Theme.spacingMD) {
            if viewModel.isLoadingMenu {
                VStack(spacing: Theme.spacingLG) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(Color.appAccent)

                    Text("Researching \(restaurant.name)...")
                        .font(.system(size: Theme.bodySize, weight: .semibold))
                        .foregroundStyle(Color.appTextPrimary)

                    Text("Finding the best menu items for you")
                        .font(.system(size: Theme.captionSize))
                        .foregroundStyle(Color.appTextSecondary)

                    Text("This may take up to 2 minutes for accurate results")
                        .font(.system(size: Theme.miniSize))
                        .foregroundStyle(Color.appTextTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.spacingHuge)
            } else if viewModel.displayedItems.isEmpty {
                VStack(spacing: Theme.spacingSM) {
                    Image(systemName: "menucard")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.appTextTertiary)
                    Text(viewModel.selectedFilter == .bestForYou
                         ? "No top-scored items — try \"All items\""
                         : "No menu items found")
                        .font(.system(size: Theme.bodySize))
                        .foregroundStyle(Color.appTextSecondary)
                }
                .padding(.vertical, Theme.spacingHuge)
            } else {
                ForEach(viewModel.displayedItems, id: \.0.id) { item, score in
                    MenuItemCard(item: item, score: score, profile: profile)
                }
            }
        }
        .padding(.horizontal, Theme.spacingLG)
        .padding(.top, Theme.spacingMD)
    }
}
