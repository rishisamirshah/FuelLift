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
}

// MARK: - Color

extension Color {
    static let appOrange = Color.orange
    static let appGreen = Color.green
    static let appBlue = Color.blue
    static let appRed = Color.red
    static let appProtein = Color.blue
    static let appCarbs = Color.orange
    static let appFat = Color.purple
    static let appCalories = Color.green
    static let appWater = Color.cyan
}

// MARK: - View

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
