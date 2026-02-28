import SwiftUI

struct TrendRow: View {
    let label: String
    let value: Double
    let unit: String
    let trend: TrendDirection
    var maxAbsValue: Double = 5.0

    enum TrendDirection {
        case increase
        case decrease
        case noChange

        var icon: String {
            switch self {
            case .increase: return "arrow.up.right"
            case .decrease: return "arrow.down.right"
            case .noChange: return "arrow.right"
            }
        }

        var color: Color {
            switch self {
            case .increase: return .red
            case .decrease: return Color.appCaloriesColor
            case .noChange: return Color.appTextSecondary
            }
        }

        var label: String {
            switch self {
            case .increase: return "Increase"
            case .decrease: return "Decrease"
            case .noChange: return "No change"
            }
        }
    }

    private var barWidth: CGFloat {
        guard maxAbsValue > 0 else { return 0 }
        return CGFloat(min(abs(value) / maxAbsValue, 1.0))
    }

    var body: some View {
        HStack(spacing: Theme.spacingMD) {
            Text(label)
                .font(.system(size: Theme.captionSize, weight: .medium))
                .foregroundStyle(Color.appTextSecondary)
                .frame(width: 50, alignment: .leading)

            // Mini bar
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 3)
                    .fill(trend.color.opacity(0.7))
                    .frame(width: geo.size.width * barWidth, height: 6)
                    .frame(maxHeight: .infinity, alignment: .center)
            }
            .frame(height: 20)

            Text(String(format: "%+.1f %@", value, unit))
                .font(.system(size: Theme.captionSize, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)
                .frame(width: 70, alignment: .trailing)

            Image(systemName: trend.icon)
                .font(.system(size: Theme.miniSize, weight: .bold))
                .foregroundStyle(trend.color)

            Text(trend.label)
                .font(.system(size: Theme.miniSize))
                .foregroundStyle(Color.appTextTertiary)
                .frame(width: 65, alignment: .leading)
        }
        .padding(.vertical, Theme.spacingXS)
    }
}

#Preview {
    VStack(spacing: 0) {
        TrendRow(label: "3 days", value: -0.5, unit: "lbs", trend: .decrease)
        Divider()
        TrendRow(label: "7 days", value: 1.2, unit: "lbs", trend: .increase)
        Divider()
        TrendRow(label: "30 days", value: 0, unit: "lbs", trend: .noChange)
    }
    .padding()
    .background(Color.appCardBackground)
    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
    .padding()
    .background(Color.appBackground)
}
