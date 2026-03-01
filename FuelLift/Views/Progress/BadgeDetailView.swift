import SwiftUI
import UIKit

struct BadgeDetailView: View {
    let badge: Badge

    @Environment(\.dismiss) private var dismiss

    private var definition: BadgeDefinition? {
        BadgeDefinition.all.first { $0.key.rawValue == badge.key }
    }

    private var badgeCategory: BadgeCategory? {
        definition?.category
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingXXL) {
                // Badge Icon
                ZStack {
                    if badge.isEarned, let def = definition, def.hasCustomImage, let imgName = def.imageName {
                        // Custom pixel art badge — no background circle
                        Image(imgName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 140, height: 140)
                    } else {
                        if badge.isEarned, let category = badgeCategory {
                            Circle()
                                .fill(category.gradient)
                                .frame(width: 140, height: 140)
                                .shadow(color: category.gradientColors[0].opacity(0.4), radius: 10, y: 5)
                        } else {
                            Circle()
                                .fill(Color.appBadgeLocked.opacity(0.1))
                                .frame(width: 140, height: 140)
                        }

                        Image(systemName: badge.isEarned ? badge.iconName : "star.fill")
                            .font(.system(size: 56, weight: .semibold))
                            .foregroundStyle(badge.isEarned ? Color.white : Color.appBadgeLocked)
                    }
                }
                .padding(.top, Theme.spacingHuge)

                // Badge Info
                VStack(spacing: Theme.spacingSM) {
                    Text(badge.name)
                        .font(.system(size: Theme.headlineSize, weight: .bold))
                        .foregroundStyle(Color.appTextPrimary)

                    Text(badge.badgeDescription)
                        .font(.system(size: Theme.bodySize))
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.spacingXXL)
                }

                // Requirement Card
                VStack(spacing: Theme.spacingMD) {
                    HStack {
                        Image(systemName: "target")
                            .foregroundStyle(Color.appAccent)
                        Text("Requirement")
                            .font(.system(size: Theme.subheadlineSize, weight: .semibold))
                            .foregroundStyle(Color.appTextPrimary)
                        Spacer()
                    }

                    Text(badge.requirement)
                        .font(.system(size: Theme.bodySize))
                        .foregroundStyle(Color.appTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .cardStyle()

                // Earned Date Card
                if let earnedDate = badge.earnedDate {
                    VStack(spacing: Theme.spacingMD) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.appCaloriesColor)
                            Text("Earned")
                                .font(.system(size: Theme.subheadlineSize, weight: .semibold))
                                .foregroundStyle(Color.appTextPrimary)
                            Spacer()
                        }

                        Text(earnedDate.formatted(date: .long, time: .omitted))
                            .font(.system(size: Theme.bodySize))
                            .foregroundStyle(Color.appTextSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .cardStyle()
                }

                // Share Button
                if badge.isEarned {
                    ShareLink(
                        item: "I earned the \"\(badge.name)\" badge on FuelLift! 💪",
                        subject: Text("Badge Earned!"),
                        message: Text("Check out my achievement on FuelLift")
                    ) {
                        HStack(spacing: Theme.spacingSM) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Badge")
                        }
                        .font(.system(size: Theme.subheadlineSize, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.spacingMD)
                        .background(Color.appAccent)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                    }
                    .padding(.horizontal, Theme.spacingLG)
                }

                Spacer(minLength: Theme.spacingHuge)
            }
            .padding(.horizontal, Theme.spacingLG)
        }
        .screenBackground()
        .navigationTitle("Badge Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
