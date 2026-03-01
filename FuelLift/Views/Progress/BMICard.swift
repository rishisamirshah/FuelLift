import SwiftUI

struct BMICard: View {
    let weightLbs: Double
    let heightCM: Double

    private var bmi: Double {
        guard heightCM > 0 else { return 0 }
        let weightKG = weightLbs * 0.453592
        let heightM = heightCM / 100.0
        return weightKG / (heightM * heightM)
    }

    private var category: BMICategory {
        switch bmi {
        case ..<18.5: return .underweight
        case 18.5..<25: return .healthy
        case 25..<30: return .overweight
        default: return .obese
        }
    }

    private var gaugePosition: CGFloat {
        // Map BMI 15-40 to 0-1
        let clamped = min(max(bmi, 15), 40)
        return CGFloat((clamped - 15) / 25)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingLG) {
            HStack {
                Text("Your BMI")
                    .font(.system(size: Theme.subheadlineSize, weight: .bold))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Image("icon_info")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 20, height: 20)
            }

            // BMI value + category
            HStack(alignment: .firstTextBaseline, spacing: Theme.spacingSM) {
                Text(String(format: "%.1f", bmi))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)

                HStack(spacing: 4) {
                    Text("Your weight is")
                        .font(.system(size: Theme.captionSize))
                        .foregroundStyle(Color.appTextSecondary)
                    Text(category.label)
                        .font(.system(size: Theme.captionSize, weight: .semibold))
                        .foregroundStyle(category.color)
                }
            }

            // Gauge bar
            GeometryReader { geo in
                let totalWidth = geo.size.width
                ZStack(alignment: .leading) {
                    // Colored segments
                    HStack(spacing: 2) {
                        // Underweight (<18.5): 3.5/25 = 14%
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.appProteinColor)
                            .frame(width: totalWidth * 0.14)
                        // Healthy (18.5-24.9): 6.4/25 = 25.6%
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.appCaloriesColor)
                            .frame(width: totalWidth * 0.256)
                        // Overweight (25-29.9): 5/25 = 20%
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.appCarbsColor)
                            .frame(width: totalWidth * 0.20)
                        // Obese (30+): 10/25 = 40%
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.appFatColor)
                    }
                    .frame(height: 10)

                    // Indicator
                    Circle()
                        .fill(Color.appTextPrimary)
                        .frame(width: 14, height: 14)
                        .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                        .offset(x: totalWidth * gaugePosition - 7)
                }
            }
            .frame(height: 14)

            // Legend
            HStack(spacing: 0) {
                legendItem(color: Color.appProteinColor, label: "Underweight", range: "<18.5")
                Spacer()
                legendItem(color: Color.appCaloriesColor, label: "Healthy", range: "18.5–24.9")
                Spacer()
                legendItem(color: Color.appCarbsColor, label: "Overweight", range: "25.0–29.9")
                Spacer()
                legendItem(color: Color.appFatColor, label: "Obese", range: ">30.0")
            }
        }
        .cardStyle()
    }

    private func legendItem(color: Color, label: String, range: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            VStack(alignment: .leading, spacing: 0) {
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(Color.appTextSecondary)
                Text(range)
                    .font(.system(size: 8))
                    .foregroundStyle(Color.appTextTertiary)
            }
        }
    }
}

private enum BMICategory {
    case underweight, healthy, overweight, obese

    var label: String {
        switch self {
        case .underweight: return "Underweight"
        case .healthy: return "Healthy"
        case .overweight: return "Overweight"
        case .obese: return "Obese"
        }
    }

    var color: Color {
        switch self {
        case .underweight: return Color.appProteinColor
        case .healthy: return Color.appCaloriesColor
        case .overweight: return Color.appCarbsColor
        case .obese: return Color.appFatColor
        }
    }
}

#Preview {
    BMICard(weightLbs: 187, heightCM: 178)
        .padding()
        .background(Color.appBackground)
}
