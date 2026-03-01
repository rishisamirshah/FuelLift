import SwiftUI

// MARK: - Date

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var shortFormatted: String {
        formatted(date: .abbreviated, time: .omitted)
    }

    var timeFormatted: String {
        formatted(date: .omitted, time: .shortened)
    }

    var dayOfWeek: String {
        formatted(.dateTime.weekday(.abbreviated))
    }

    var relativeFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

// MARK: - Double

extension Double {
    var oneDecimal: String {
        String(format: "%.1f", self)
    }

    var noDecimal: String {
        String(format: "%.0f", self)
    }
}

// MARK: - Int

extension Int {
    var formattedWithComma: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }

    var ordinalString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

// MARK: - Color (Legacy aliases)

extension Color {
    static let appOrange = Color.appAccent
    static let appGreen = Color.appCaloriesColor
    static let appBlue = Color.appProteinColor
    static let appRed = Color.appFatColor
    static let appProtein = Color.appProteinColor
    static let appCarbs = Color.appCarbsColor
    static let appFat = Color.appFatColor
    static let appCalories = Color.appCaloriesColor
    static let appWater = Color.appWaterColor
}

// MARK: - Pixel Art Image Helper

extension Image {
    /// Render a pixel art asset with crisp nearest-neighbor scaling
    func pixelArt() -> some View {
        self
            .resizable()
            .renderingMode(.original)
            .interpolation(.none)
            .aspectRatio(contentMode: .fit)
    }
}

// MARK: - Scanline Overlay Shape

struct ScanlinePattern: Shape {
    var spacing: CGFloat = 4

    func path(in rect: CGRect) -> Path {
        var path = Path()
        var y: CGFloat = 0
        while y < rect.height {
            path.addRect(CGRect(x: 0, y: y, width: rect.width, height: 1))
            y += spacing
        }
        return path
    }
}

// MARK: - Pixel Corner Border Shape

struct PixelBorder: Shape {
    var step: CGFloat = 4

    func path(in rect: CGRect) -> Path {
        let s = step
        var path = Path()

        // Top-left stepped corner
        path.move(to: CGPoint(x: s * 2, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX - s * 2, y: 0))
        // Top-right stepped corner
        path.addLine(to: CGPoint(x: rect.maxX - s * 2, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX - s, y: s))
        path.addLine(to: CGPoint(x: rect.maxX, y: s * 2))
        // Right edge
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - s * 2))
        // Bottom-right stepped corner
        path.addLine(to: CGPoint(x: rect.maxX - s, y: rect.maxY - s))
        path.addLine(to: CGPoint(x: rect.maxX - s * 2, y: rect.maxY))
        // Bottom edge
        path.addLine(to: CGPoint(x: s * 2, y: rect.maxY))
        // Bottom-left stepped corner
        path.addLine(to: CGPoint(x: s, y: rect.maxY - s))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY - s * 2))
        // Left edge
        path.addLine(to: CGPoint(x: 0, y: s * 2))
        // Top-left stepped corner
        path.addLine(to: CGPoint(x: s, y: s))
        path.closeSubpath()

        return path
    }
}

// MARK: - View Modifiers

extension View {
    /// Primary card — adaptive background with accent border (dark: glow, light: shadow)
    func cardStyle() -> some View {
        self
            .padding(Theme.spacingLG)
            .background(Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusLG)
                    .strokeBorder(Color.appBorderAccent, lineWidth: Theme.borderWidth)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 4, y: 2)
    }

    /// Secondary card — lighter background, no accent border
    func secondaryCardStyle() -> some View {
        self
            .padding(Theme.spacingLG)
            .background(Color.appCardSecondary)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusMD)
                    .strokeBorder(Color.appBorder, lineWidth: Theme.borderWidth)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 3, y: 1)
    }

    /// Pixel-stepped card — retro corner shape with orange accent
    func pixelCardStyle() -> some View {
        self
            .padding(Theme.spacingLG)
            .background(
                PixelBorder(step: Theme.pixelStep)
                    .fill(Color.appCardBackground)
            )
            .overlay(
                PixelBorder(step: Theme.pixelStep)
                    .stroke(Color.appBorderAccent, lineWidth: Theme.borderWidth)
            )
    }

    /// Retro pixel art styled button background
    func pixelButtonStyle() -> some View {
        self
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, Theme.spacingLG)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.cornerRadiusSM)
                        .fill(Color.appCardBackground)
                    RoundedRectangle(cornerRadius: Theme.cornerRadiusSM)
                        .strokeBorder(
                            LinearGradient.accentGlow,
                            lineWidth: Theme.borderWidthThick
                        )
                }
            )
    }

    /// Primary action button — filled orange with glow
    func primaryButtonStyle() -> some View {
        self
            .font(.system(size: Theme.subheadlineSize, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.spacingMD)
            .background(Color.appAccent)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
            .shadow(color: Color.appAccent.opacity(Theme.glowOpacity), radius: Theme.glowRadius, y: 2)
    }

    /// Section header text styling
    func sectionHeaderStyle() -> some View {
        self
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(Color.appTextPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Screen background — deep dark
    func screenBackground() -> some View {
        self
            .background(Color.appBackground)
    }

    /// Subtle orange glow effect on any view
    func accentGlow(radius: CGFloat = Theme.glowRadius) -> some View {
        self
            .shadow(color: Color.appAccent.opacity(Theme.glowOpacity), radius: radius)
    }

    /// Scanline overlay for retro CRT atmosphere
    func scanlineOverlay(opacity: Double = 0.03) -> some View {
        self
            .overlay(
                ScanlinePattern(spacing: 4)
                    .fill(Color.white.opacity(opacity))
                    .allowsHitTesting(false)
            )
    }

    /// Conditional modifier — applies transform only when condition is true
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Pixel divider — thin line with subtle accent
    func pixelDivider() -> some View {
        self
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.appBorder)
                    .frame(height: 1)
            }
    }
}
