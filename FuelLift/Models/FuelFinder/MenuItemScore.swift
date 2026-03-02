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

    /// Create a score directly from AI-provided values (preferred path)
    static func fromAI(score: Int, rationale: String) -> MenuItemScore {
        let clamped = max(0, min(100, score))
        let label: ScoreLabel
        switch clamped {
        case 90...100: label = .great
        case 70..<90:  label = .good
        case 50..<70:  label = .fair
        default:       label = .poor
        }
        return MenuItemScore(score: clamped, label: label, rationale: rationale)
    }

    /// Fallback scoring when AI scores aren't available
    static func calculate(for item: MenuItem, profile: UserProfile) -> MenuItemScore {
        // If Gemini provided a personalized user_match_score, use it directly
        if let aiScore = item.userMatchScore, let aiRationale = item.userMatchRationale {
            return fromAI(score: aiScore, rationale: aiRationale)
        }

        // Fallback: use Gemini health_score with basic adjustments
        let baseScore = item.healthScore ?? 50
        let goal = profile.goal ?? "maintenance"
        var score = baseScore
        var rationale = ""

        switch goal {
        case "weight_loss", "Lose Fat", "lose_fat":
            // Bonus for low cal + high protein
            if item.calories <= 500 && item.proteinG >= 20 { score += 10 }
            if item.calories > 700 { score -= 15 }
            rationale = "\(item.calories) cal, \(Int(item.proteinG))g protein"

        case "muscle_gain", "Build Muscle", "build_muscle":
            // Bonus for high protein
            if item.proteinG >= 30 { score += 15 }
            if item.proteinG < 15 { score -= 10 }
            rationale = "\(Int(item.proteinG))g protein, \(item.calories) cal"

        default:
            rationale = "Based on overall nutritional quality"
        }

        score = max(0, min(100, score))
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
