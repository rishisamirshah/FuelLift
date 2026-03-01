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
                            .renderingMode(.original)
                            .interpolation(.none)
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
                    // Unearned — show desaturated preview of actual badge with lock overlay
                    ZStack {
                        if let imageName, UIImage(named: imageName) != nil {
                            // Show the actual badge image desaturated and transparent
                            Image(imageName)
                                .resizable()
                                .renderingMode(.original)
                                .interpolation(.none)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: Theme.badgeIconSize, height: Theme.badgeIconSize)
                                .saturation(0)
                                .opacity(0.25)
                        } else if let category {
                            // Fallback: gradient circle + icon, desaturated
                            Circle()
                                .fill(category.gradient)
                                .frame(width: Theme.badgeIconSize, height: Theme.badgeIconSize)
                                .overlay(
                                    Image(systemName: iconName)
                                        .font(.system(size: 28, weight: .semibold))
                                        .foregroundStyle(Color.white)
                                )
                                .saturation(0)
                                .opacity(0.25)
                        } else {
                            // Fallback: SF Symbol, desaturated
                            Image(systemName: iconName)
                                .font(.system(size: 36))
                                .foregroundStyle(Color.appTextTertiary)
                                .frame(width: Theme.badgeIconSize, height: Theme.badgeIconSize)
                                .opacity(0.25)
                        }

                        // Lock icon overlay
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.appTextTertiary)
                            .padding(4)
                            .background(
                                Circle()
                                    .fill(Color.appCardBackground.opacity(0.9))
                            )
                            .offset(x: Theme.badgeIconSize / 2 - 10, y: Theme.badgeIconSize / 2 - 10)
                    }
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
