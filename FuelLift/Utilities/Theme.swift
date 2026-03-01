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

    // MARK: Glow
    static let glowRadius: CGFloat = 8
    static let glowRadiusLG: CGFloat = 16
    static let glowOpacity: Double = 0.35

    // MARK: Borders
    static let borderWidth: CGFloat = 1
    static let borderWidthThick: CGFloat = 2
    static let pixelStep: CGFloat = 4
}

// MARK: - Retro Dark Palette

extension Color {
    // Core backgrounds — intentional dark, not system adaptive
    static let appBackground = Color(red: 0.03, green: 0.03, blue: 0.06)           // #08080F
    static let appCardBackground = Color(red: 0.07, green: 0.07, blue: 0.12)       // #12121E
    static let appCardSecondary = Color(red: 0.10, green: 0.10, blue: 0.16)        // #1A1A2A
    static let appGroupedBackground = Color(red: 0.05, green: 0.05, blue: 0.09)    // #0D0D17

    // Accent — hot arcade orange
    static let appAccent = Color(red: 1.0, green: 0.42, blue: 0.0)                 // #FF6B00
    static let appAccentBright = Color(red: 1.0, green: 0.55, blue: 0.15)          // #FF8C26
    static let appAccentDim = Color(red: 0.80, green: 0.33, blue: 0.0)             // #CC5500

    // Macro colors — neon-tinted for dark backgrounds
    static let appProteinColor = Color(red: 0.35, green: 0.65, blue: 1.0)          // #59A5FF
    static let appCarbsColor = Color(red: 1.0, green: 0.75, blue: 0.20)            // #FFBF33
    static let appFatColor = Color(red: 1.0, green: 0.30, blue: 0.35)              // #FF4D59
    static let appCaloriesColor = Color(red: 0.40, green: 0.90, blue: 0.25)        // #66E640
    static let appWaterColor = Color(red: 0.25, green: 0.85, blue: 0.90)           // #40D9E6

    // Status
    static let appStreakColor = Color(red: 1.0, green: 0.58, blue: 0.0)            // #FF9500
    static let appPRColor = Color(red: 0.0, green: 0.80, blue: 0.90)              // #00CCE6

    // PR variants
    static let appPR1RM = Color(red: 0.0, green: 0.80, blue: 0.90)
    static let appPRVolume = Color(red: 0.35, green: 0.78, blue: 0.35)
    static let appPRWeight = Color(red: 1.0, green: 0.80, blue: 0.20)

    // Text — pure white hierarchy on dark
    static let appTextPrimary = Color.white
    static let appTextSecondary = Color.white.opacity(0.60)
    static let appTextTertiary = Color.white.opacity(0.30)

    // Workout
    static let appWorkoutGreen = Color(red: 0.30, green: 0.80, blue: 0.35)

    // Badge states
    static let appBadgeEarned = Color(red: 1.0, green: 0.42, blue: 0.0)
    static let appBadgeLocked = Color.white.opacity(0.20)

    // Border / divider
    static let appBorder = Color.white.opacity(0.08)
    static let appBorderAccent = Color(red: 1.0, green: 0.42, blue: 0.0).opacity(0.30)
}

// MARK: - Gradients

extension LinearGradient {
    static let calorieRingGradient = LinearGradient(
        colors: [Color.appCaloriesColor, Color.appCaloriesColor.opacity(0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let proteinRingGradient = LinearGradient(
        colors: [Color.appProteinColor, Color.appProteinColor.opacity(0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let carbsRingGradient = LinearGradient(
        colors: [Color.appCarbsColor, Color.appCarbsColor.opacity(0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let fatRingGradient = LinearGradient(
        colors: [Color.appFatColor, Color.appFatColor.opacity(0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let streakGradient = LinearGradient(
        colors: [Color.appStreakColor, Color.red],
        startPoint: .top,
        endPoint: .bottom
    )

    static let accentGlow = LinearGradient(
        colors: [Color.appAccent.opacity(0.6), Color.appAccent.opacity(0.15)],
        startPoint: .top,
        endPoint: .bottom
    )
}
