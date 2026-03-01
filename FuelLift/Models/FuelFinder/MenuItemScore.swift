import SwiftUI

struct MenuItemScore: Hashable {
    let score: Int              // 0-100
    let label: ScoreLabel
    let rationale: String

    enum ScoreLabel: String, Hashable {
        case great = "GREAT"
        case good = "GOOD"
        case fair = "FAIR"
        case poor = "POOR"

        var color: Color {
            switch self {
            case .great: return .green
            case .good:  return Color.appProteinColor
            case .fair:  return Color.appCarbsColor
            case .poor:  return Color.appFatColor
            }
        }
    }

    static func calculate(for item: MenuItem, profile: UserProfile) -> MenuItemScore {
        let goal = profile.goal ?? "maintenance"
        let score: Int
        let rationale: String

        switch goal {
        case "weight_loss", "Lose Fat", "lose_fat":
            // Prioritize: low calorie (40pts) + high protein density (40pts) + low fat (20pts)
            let calScore = max(0, 40 - max(0, (item.calories - 400)) / 10)
            let proteinDensity = item.calories > 0 ? (item.proteinG * 4.0) / Double(item.calories) : 0
            let proteinScore = Int(min(40, proteinDensity * 100))
            let fatScore = max(0, 20 - Int(item.fatG) / 2)
            score = min(100, calScore + proteinScore + fatScore)
            rationale = "\(item.calories) cal, \(Int(item.proteinG))g protein — \(proteinDensity > 0.3 ? "high" : "moderate") protein density"

        case "muscle_gain", "Build Muscle", "build_muscle":
            // Prioritize: high protein (50pts) + sufficient calories (30pts) + carbs (20pts)
            let proteinScore = min(50, Int(item.proteinG) * 2)
            let calScore = min(30, item.calories / 20)
            let carbScore = min(20, Int(item.carbsG) / 3)
            score = min(100, proteinScore + calScore + carbScore)
            rationale = "\(Int(item.proteinG))g protein, \(item.calories) cal — \(item.proteinG >= 30 ? "great" : "moderate") for muscle building"

        default: // "maintenance"
            // Balanced deviation from 1/3 daily macro targets
            let targetCal = Double(profile.calorieGoal) / 3.0
            let targetP = Double(profile.proteinGoal) / 3.0
            let targetC = Double(profile.carbsGoal) / 3.0
            let targetF = Double(profile.fatGoal) / 3.0

            let calDev = targetCal > 0 ? abs(Double(item.calories) - targetCal) / targetCal : 1.0
            let pDev = targetP > 0 ? abs(item.proteinG - targetP) / targetP : 1.0
            let cDev = targetC > 0 ? abs(item.carbsG - targetC) / targetC : 1.0
            let fDev = targetF > 0 ? abs(item.fatG - targetF) / targetF : 1.0

            let avgDeviation = (calDev + pDev + cDev + fDev) / 4.0
            score = max(0, min(100, Int(100.0 * (1.0 - avgDeviation))))
            rationale = "Balanced macros — \(avgDeviation < 0.3 ? "close to" : "deviates from") your daily targets"
        }

        let label: ScoreLabel
        switch score {
        case 90...100: label = .great
        case 70..<90:  label = .good
        case 50..<70:  label = .fair
        default:       label = .poor
        }

        return MenuItemScore(score: score, label: label, rationale: rationale)
    }
}
