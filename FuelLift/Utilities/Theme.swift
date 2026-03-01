import SwiftUI
import UIKit

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

// MARK: - Adaptive Palette (Dark + Light)

extension Color {
    // Core backgrounds — dark: retro arcade, light: clean white
    static let appBackground = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.03, green: 0.03, blue: 0.06, alpha: 1)       // #08080F
            : UIColor(red: 0.965, green: 0.965, blue: 0.975, alpha: 1)    // #F7F7F9
    })
    static let appCardBackground = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.07, green: 0.07, blue: 0.12, alpha: 1)       // #12121E
            : UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1)          // #FFFFFF
    })
    static let appCardSecondary = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.10, green: 0.10, blue: 0.16, alpha: 1)       // #1A1A2A
            : UIColor(red: 0.94, green: 0.94, blue: 0.96, alpha: 1)       // #F0F0F5
    })
    static let appGroupedBackground = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.05, green: 0.05, blue: 0.09, alpha: 1)       // #0D0D17
            : UIColor(red: 0.93, green: 0.93, blue: 0.95, alpha: 1)       // #EEEEF3
    })

    // Accent — hot arcade orange (same in both modes)
    static let appAccent = Color(red: 1.0, green: 0.42, blue: 0.0)                 // #FF6B00
    static let appAccentBright = Color(red: 1.0, green: 0.55, blue: 0.15)          // #FF8C26
    static let appAccentDim = Color(red: 0.80, green: 0.33, blue: 0.0)             // #CC5500

    // Macro colors — vibrant in dark, slightly deeper in light for contrast
    static let appProteinColor = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.35, green: 0.65, blue: 1.0, alpha: 1)        // #59A5FF
            : UIColor(red: 0.20, green: 0.50, blue: 0.90, alpha: 1)       // #3380E6
    })
    static let appCarbsColor = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 1.0, green: 0.75, blue: 0.20, alpha: 1)        // #FFBF33
            : UIColor(red: 0.85, green: 0.62, blue: 0.05, alpha: 1)       // #D99E0D
    })
    static let appFatColor = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 1.0, green: 0.30, blue: 0.35, alpha: 1)        // #FF4D59
            : UIColor(red: 0.88, green: 0.20, blue: 0.25, alpha: 1)       // #E03340
    })
    static let appCaloriesColor = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.40, green: 0.90, blue: 0.25, alpha: 1)       // #66E640
            : UIColor(red: 0.25, green: 0.70, blue: 0.15, alpha: 1)       // #40B326
    })
    static let appWaterColor = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.25, green: 0.85, blue: 0.90, alpha: 1)       // #40D9E6
            : UIColor(red: 0.15, green: 0.65, blue: 0.75, alpha: 1)       // #26A6BF
    })

    // Status
    static let appStreakColor = Color(red: 1.0, green: 0.58, blue: 0.0)            // #FF9500
    static let appPRColor = Color(red: 0.0, green: 0.80, blue: 0.90)              // #00CCE6

    // PR variants
    static let appPR1RM = Color(red: 0.0, green: 0.80, blue: 0.90)
    static let appPRVolume = Color(red: 0.35, green: 0.78, blue: 0.35)
    static let appPRWeight = Color(red: 1.0, green: 0.80, blue: 0.20)

    // Text — white on dark, near-black on light
    static let appTextPrimary = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white
            : UIColor(red: 0.11, green: 0.11, blue: 0.18, alpha: 1)       // #1C1C2E
    })
    static let appTextSecondary = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.60)
            : UIColor.black.withAlphaComponent(0.55)
    })
    static let appTextTertiary = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.30)
            : UIColor.black.withAlphaComponent(0.25)
    })

    // Workout
    static let appWorkoutGreen = Color(red: 0.30, green: 0.80, blue: 0.35)

    // Badge states
    static let appBadgeEarned = Color(red: 1.0, green: 0.42, blue: 0.0)
    static let appBadgeLocked = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.20)
            : UIColor.black.withAlphaComponent(0.15)
    })

    // Border / divider
    static let appBorder = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.08)
            : UIColor.black.withAlphaComponent(0.08)
    })
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

    static let stepsRingGradient = LinearGradient(
        colors: [Color.appAccent, Color.appAccentBright],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let burnedRingGradient = LinearGradient(
        colors: [Color.appFatColor, Color.appFatColor.opacity(0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let waterRingGradient = LinearGradient(
        colors: [Color.appWaterColor, Color.appWaterColor.opacity(0.6)],
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
