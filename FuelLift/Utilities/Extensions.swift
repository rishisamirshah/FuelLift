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

// MARK: - Color (Legacy aliases — use Theme colors for new code)

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

// MARK: - View Modifiers

extension View {
    func cardStyle() -> some View {
        self
            .padding(Theme.spacingLG)
            .background(Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusLG)
                    .strokeBorder(Color.appAccent.opacity(0.25), lineWidth: 1)
            )
    }

    func secondaryCardStyle() -> some View {
        self
            .padding(Theme.spacingLG)
            .background(Color.appCardSecondary)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
    }

    /// Retro pixel art styled button background
    func pixelButtonStyle() -> some View {
        self
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, Theme.spacingLG)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.appCardBackground)
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.appAccent.opacity(0.6), Color.appAccent.opacity(0.2)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                    // Inner highlight line at top
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Color.appAccent.opacity(0.1), lineWidth: 1)
                        .padding(2)
                }
            )
    }

    func sectionHeaderStyle() -> some View {
        self
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(Color.appTextPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    func screenBackground() -> some View {
        self
            .background(Color.appBackground)
    }
}
