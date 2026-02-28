import SwiftUI

// MARK: - Design Tokens

enum Theme {
    // MARK: Spacing
    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 12
    static let spacingLG: CGFloat = 16
    static let spacingXL: CGFloat = 20
    static let spacingXXL: CGFloat = 24
    static let spacingHuge: CGFloat = 32

    // MARK: Corner Radius
    static let cornerRadiusSM: CGFloat = 8
    static let cornerRadiusMD: CGFloat = 12
    static let cornerRadiusLG: CGFloat = 16
    static let cornerRadiusXL: CGFloat = 20
    static let cornerRadiusFull: CGFloat = 100

    // MARK: Typography
    static let titleSize: CGFloat = 34
    static let headlineSize: CGFloat = 22
    static let subheadlineSize: CGFloat = 17
    static let bodySize: CGFloat = 15
    static let captionSize: CGFloat = 13
    static let miniSize: CGFloat = 11

    // MARK: Ring Sizes
    static let calorieRingSize: CGFloat = 120
    static let macroRingSize: CGFloat = 56
    static let ringLineWidth: CGFloat = 12
    static let macroRingLineWidth: CGFloat = 6

    // MARK: Icon Sizes
    static let tabBarIconSize: CGFloat = 24
    static let inlineIconSize: CGFloat = 20
    static let badgeIconSize: CGFloat = 64
}

// MARK: - Adaptive Colors

extension Color {
    // Background colors — adaptive
    static let appBackground = Color(UIColor.systemBackground)
    static let appCardBackground = Color(UIColor.secondarySystemGroupedBackground)
    static let appCardSecondary = Color(UIColor.tertiarySystemGroupedBackground)
    static let appGroupedBackground = Color(UIColor.systemGroupedBackground)

    // Semantic colors
    static let appAccent = Color.orange
    static let appProteinColor = Color(red: 0.29, green: 0.56, blue: 0.85)   // #4A90D9
    static let appCarbsColor = Color(red: 0.96, green: 0.65, blue: 0.14)      // #F5A623
    static let appFatColor = Color(red: 0.82, green: 0.01, blue: 0.11)        // #D0021B
    static let appCaloriesColor = Color(red: 0.49, green: 0.83, blue: 0.13)   // #7ED321
    static let appWaterColor = Color(red: 0.31, green: 0.89, blue: 0.76)      // #50E3C2
    static let appStreakColor = Color(red: 1.0, green: 0.58, blue: 0.0)       // #FF9500
    static let appPRColor = Color(red: 0.0, green: 0.74, blue: 0.83)          // #00BCD4

    // PR badge colors
    static let appPR1RM = Color(red: 0.0, green: 0.74, blue: 0.83)       // teal
    static let appPRVolume = Color(red: 0.30, green: 0.69, blue: 0.31)   // green
    static let appPRWeight = Color(red: 0.98, green: 0.75, blue: 0.18)   // yellow

    // Text colors — adaptive
    static let appTextPrimary = Color(UIColor.label)
    static let appTextSecondary = Color(UIColor.secondaryLabel)
    static let appTextTertiary = Color(UIColor.tertiaryLabel)

    // Workout-specific
    static let appWorkoutGreen = Color(red: 0.30, green: 0.69, blue: 0.31)

    // Badge states
    static let appBadgeEarned = Color.orange
    static let appBadgeLocked = Color(UIColor.tertiaryLabel)
}

// MARK: - Gradients

extension LinearGradient {
    static let calorieRingGradient = LinearGradient(
        colors: [Color.appCaloriesColor, Color.appCaloriesColor.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let proteinRingGradient = LinearGradient(
        colors: [Color.appProteinColor, Color.appProteinColor.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let carbsRingGradient = LinearGradient(
        colors: [Color.appCarbsColor, Color.appCarbsColor.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let fatRingGradient = LinearGradient(
        colors: [Color.appFatColor, Color.appFatColor.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let streakGradient = LinearGradient(
        colors: [Color.appStreakColor, Color.red],
        startPoint: .top,
        endPoint: .bottom
    )
}
