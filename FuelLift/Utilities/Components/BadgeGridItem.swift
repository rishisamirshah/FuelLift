import SwiftUI
import UIKit

struct BadgeGridItem: View {
    let name: String
    let iconName: String
    let requirement: String
    let isEarned: Bool
    var earnedDate: Date? = nil
    var imageName: String? = nil
    var category: BadgeCategory? = nil

    var body: some View {
        VStack(spacing: Theme.spacingSM) {
            ZStack {
                if isEarned {
                    if let imageName, UIImage(named: imageName) != nil {
                        // Earned badge — custom image
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Theme.badgeIconSize, height: Theme.badgeIconSize)
                    } else if let category {
                        // Earned badge — gradient circle + white icon
                        Circle()
                            .fill(category.gradient)
                            .frame(width: Theme.badgeIconSize, height: Theme.badgeIconSize)
                            .shadow(color: category.gradientColors[0].opacity(0.4), radius: 6, y: 3)
                            .overlay(
                                Image(systemName: iconName)
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundStyle(Color.white)
                            )
                    } else {
                        // Earned badge — SF Symbol fallback (no category)
                        Image(systemName: iconName)
                            .font(.system(size: 36))
                            .foregroundStyle(Color.appBadgeEarned)
                            .frame(width: Theme.badgeIconSize, height: Theme.badgeIconSize)
                    }
                } else {
                    // Unearned — gray circle + star
                    Circle()
                        .fill(Color.appBadgeLocked.opacity(0.12))
                        .frame(width: Theme.badgeIconSize, height: Theme.badgeIconSize)
                        .overlay(
                            Image("icon_star")
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: 28, height: 28)
                                .opacity(0.5)
                        )
                }
            }

            VStack(spacing: 2) {
                Text(name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isEarned ? Color.appTextPrimary : Color.appTextTertiary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                Text(requirement)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.appTextTertiary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingMD)
    }
}

#Preview {
    HStack {
        BadgeGridItem(name: "Rookie", iconName: "flame.fill", requirement: "3 day streak", isEarned: true, category: .streak)
        BadgeGridItem(name: "Locked In", iconName: "flame.fill", requirement: "30 day streak", isEarned: false)
        BadgeGridItem(name: "First Rep", iconName: "dumbbell.fill", requirement: "1 workout", isEarned: true, category: .workouts)
    }
    .padding()
    .background(Color.appBackground)
}
