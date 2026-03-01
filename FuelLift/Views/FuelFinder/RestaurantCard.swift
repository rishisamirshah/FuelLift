import SwiftUI
import Shimmer

struct RestaurantCard: View {
    let restaurant: Restaurant

    var body: some View {
        HStack(spacing: Theme.spacingMD) {
            // Restaurant photo
            if let photoRef = restaurant.photoReference,
               let photoURL = GooglePlacesService.shared.photoURL(reference: photoRef) {
                AsyncImage(url: photoURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        photoPlaceholder
                    default:
                        photoPlaceholder
                            .shimmering()
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
            } else {
                photoPlaceholder
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
            }

            // Info
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text(restaurant.name)
                    .font(.system(size: Theme.subheadlineSize, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)

                // Rating + distance row
                HStack(spacing: Theme.spacingSM) {
                    if let rating = restaurant.rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.appCarbsColor)
                            Text(String(format: "%.1f", rating))
                                .font(.system(size: Theme.captionSize, weight: .medium))
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }

                    if let distance = restaurant.distanceText {
                        Text(distance)
                            .font(.system(size: Theme.captionSize))
                            .foregroundStyle(Color.appTextSecondary)
                    }

                    if let price = restaurant.priceLevelText {
                        Text(price)
                            .font(.system(size: Theme.captionSize))
                            .foregroundStyle(Color.appTextTertiary)
                    }
                }

                // Open/Closed pill
                if let isOpen = restaurant.isOpen {
                    Text(isOpen ? "Open" : "Closed")
                        .font(.system(size: Theme.miniSize, weight: .semibold))
                        .foregroundStyle(isOpen ? .green : Color.appFatColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            (isOpen ? Color.green : Color.appFatColor).opacity(0.15)
                        )
                        .clipShape(Capsule())
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.appTextTertiary)
        }
        .cardStyle()
    }

    private var photoPlaceholder: some View {
        ZStack {
            Color.appCardSecondary
            Image(systemName: "fork.knife")
                .font(.system(size: 24))
                .foregroundStyle(Color.appTextTertiary)
        }
    }
}
