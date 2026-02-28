import Foundation
import SwiftUI
import UIKit

// MARK: - Badge Category

enum BadgeCategory: String, CaseIterable {
    case streak
    case meals
    case workouts
    case strength
    case bodyProgress
    case social

    var displayName: String {
        switch self {
        case .streak: return "Streak"
        case .meals: return "Meals"
        case .workouts: return "Workouts"
        case .strength: return "Strength PRs"
        case .bodyProgress: return "Body & Progress"
        case .social: return "Social"
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .streak: return [.orange, .red]
        case .meals: return [.green, .mint]
        case .workouts: return [.blue, .cyan]
        case .strength: return [.yellow, .orange]
        case .bodyProgress: return [.purple, .pink]
        case .social: return [.teal, .blue]
        }
    }

    var gradient: LinearGradient {
        LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

// MARK: - Badge Key

enum BadgeKey: String, CaseIterable {
    // Streak (6)
    case rookie
    case gettingSerious
    case lockedIn
    case tripleThreat
    case noDaysOff
    case immortal

    // Meals (6)
    case firstBite
    case forkingAround
    case nutritionNovice
    case missionNutrition
    case theLogfather
    case calorieCounter

    // Workouts (5)
    case firstRep
    case gymRat
    case ironAddict
    case beastMode
    case legendary

    // Strength PRs (5)
    case prBreaker
    case prMachine
    case prMonster
    case volumeKing
    case millionPoundClub

    // Body/Progress (6)
    case weighIn
    case snapshot
    case transformation
    case goalCrusher
    case perfectWeek
    case hydrationHero

    // Social (3)
    case socialButterfly
    case teamPlayer
    case influencer
}

// MARK: - Badge Definition

struct BadgeDefinition {
    let key: BadgeKey
    let name: String
    let description: String
    let iconName: String
    let category: BadgeCategory
    let requirement: String
    let imageName: String?

    var hasCustomImage: Bool {
        guard let imageName else { return false }
        return UIImage(named: imageName) != nil
    }

    static let all: [BadgeDefinition] = [
        // MARK: Streak Badges
        BadgeDefinition(
            key: .rookie, name: "Rookie", description: "You've started building the habit. Three days in a row!",
            iconName: "flame.fill", category: .streak, requirement: "3 day streak", imageName: "badge_rookie"
        ),
        BadgeDefinition(
            key: .gettingSerious, name: "Getting Serious", description: "Ten days of consistency. You're building momentum.",
            iconName: "flame.fill", category: .streak, requirement: "10 day streak", imageName: "badge_gettingSerious"
        ),
        BadgeDefinition(
            key: .lockedIn, name: "Locked In", description: "50 days straight. You're locked in and unstoppable.",
            iconName: "flame.fill", category: .streak, requirement: "50 day streak", imageName: "badge_lockedIn"
        ),
        BadgeDefinition(
            key: .tripleThreat, name: "Triple Threat", description: "100 days of pure dedication. Triple digits!",
            iconName: "flame.fill", category: .streak, requirement: "100 day streak", imageName: "badge_tripleThreat"
        ),
        BadgeDefinition(
            key: .noDaysOff, name: "No Days Off", description: "365 days. A full year of consistency.",
            iconName: "flame.fill", category: .streak, requirement: "365 day streak", imageName: "badge_noDaysOff"
        ),
        BadgeDefinition(
            key: .immortal, name: "Immortal", description: "1000 days. You've transcended. Legendary status.",
            iconName: "flame.fill", category: .streak, requirement: "1000 day streak", imageName: "badge_immortal"
        ),

        // MARK: Meal Badges
        BadgeDefinition(
            key: .firstBite, name: "First Bite", description: "You logged your very first meal. The journey begins.",
            iconName: "fork.knife", category: .meals, requirement: "Log 1 meal", imageName: "badge_firstBite"
        ),
        BadgeDefinition(
            key: .forkingAround, name: "Forking Around", description: "5 meals logged. Getting the hang of tracking.",
            iconName: "fork.knife", category: .meals, requirement: "Log 5 meals", imageName: "badge_forkingAround"
        ),
        BadgeDefinition(
            key: .nutritionNovice, name: "Nutrition Novice", description: "20 meals tracked. You're learning what fuels you.",
            iconName: "leaf.fill", category: .meals, requirement: "Log 20 meals", imageName: "badge_nutritionNovice"
        ),
        BadgeDefinition(
            key: .missionNutrition, name: "Mission: Nutrition", description: "50 meals logged. Nutrition tracking is second nature.",
            iconName: "leaf.fill", category: .meals, requirement: "Log 50 meals", imageName: "badge_missionNutrition"
        ),
        BadgeDefinition(
            key: .theLogfather, name: "The Logfather", description: "500 meals. An offer your body can't refuse.",
            iconName: "fork.knife.circle.fill", category: .meals, requirement: "Log 500 meals", imageName: "badge_theLogfather"
        ),
        BadgeDefinition(
            key: .calorieCounter, name: "Calorie Counter", description: "1000 meals logged. You know exactly what you eat.",
            iconName: "fork.knife.circle.fill", category: .meals, requirement: "Log 1000 meals", imageName: "badge_calorieCounter"
        ),

        // MARK: Workout Badges
        BadgeDefinition(
            key: .firstRep, name: "First Rep", description: "Your first workout is in the books. Let's go!",
            iconName: "dumbbell.fill", category: .workouts, requirement: "Complete 1 workout", imageName: "badge_firstRep"
        ),
        BadgeDefinition(
            key: .gymRat, name: "Gym Rat", description: "10 workouts done. The gym is your second home.",
            iconName: "dumbbell.fill", category: .workouts, requirement: "Complete 10 workouts", imageName: "badge_gymRat"
        ),
        BadgeDefinition(
            key: .ironAddict, name: "Iron Addict", description: "50 workouts. Iron is your therapy.",
            iconName: "figure.strengthtraining.traditional", category: .workouts, requirement: "Complete 50 workouts", imageName: "badge_ironAddict"
        ),
        BadgeDefinition(
            key: .beastMode, name: "Beast Mode", description: "100 workouts. Beast mode permanently activated.",
            iconName: "figure.strengthtraining.traditional", category: .workouts, requirement: "Complete 100 workouts", imageName: "badge_beastMode"
        ),
        BadgeDefinition(
            key: .legendary, name: "Legendary", description: "500 workouts. You are a legend in the making.",
            iconName: "trophy.fill", category: .workouts, requirement: "Complete 500 workouts", imageName: "badge_legendary"
        ),

        // MARK: Strength PR Badges
        BadgeDefinition(
            key: .prBreaker, name: "PR Breaker", description: "You hit your first personal record!",
            iconName: "bolt.fill", category: .strength, requirement: "Hit 1 PR", imageName: "badge_prBreaker"
        ),
        BadgeDefinition(
            key: .prMachine, name: "PR Machine", description: "10 personal records broken. You're a machine.",
            iconName: "bolt.fill", category: .strength, requirement: "Hit 10 PRs", imageName: "badge_prMachine"
        ),
        BadgeDefinition(
            key: .prMonster, name: "PR Monster", description: "50 PRs smashed. Nothing stops you.",
            iconName: "crown.fill", category: .strength, requirement: "Hit 50 PRs", imageName: "badge_prMonster"
        ),
        BadgeDefinition(
            key: .volumeKing, name: "Volume King", description: "Lifted over 100,000 lbs total volume.",
            iconName: "gearshape.fill", category: .strength, requirement: "100K lbs total volume", imageName: "badge_volumeKing"
        ),
        BadgeDefinition(
            key: .millionPoundClub, name: "Million Pound Club", description: "Over 1,000,000 lbs lifted. Elite status.",
            iconName: "crown.fill", category: .strength, requirement: "1M lbs total volume", imageName: "badge_millionPoundClub"
        ),

        // MARK: Body & Progress Badges
        BadgeDefinition(
            key: .weighIn, name: "Weigh In", description: "You logged your first weigh-in. Tracking progress!",
            iconName: "scalemass.fill", category: .bodyProgress, requirement: "Log 1 weigh-in", imageName: "badge_weighIn"
        ),
        BadgeDefinition(
            key: .snapshot, name: "Snapshot", description: "First progress photo taken. Visual proof of the journey.",
            iconName: "camera.fill", category: .bodyProgress, requirement: "Take 1 progress photo", imageName: "badge_snapshot"
        ),
        BadgeDefinition(
            key: .transformation, name: "Transformation", description: "10 progress photos. Watch yourself transform.",
            iconName: "butterfly", category: .bodyProgress, requirement: "Take 10 progress photos", imageName: "badge_transformation"
        ),
        BadgeDefinition(
            key: .goalCrusher, name: "Goal Crusher", description: "You hit your calorie goal for the day. Crushed it!",
            iconName: "target", category: .bodyProgress, requirement: "Hit daily calorie goal", imageName: "badge_goalCrusher"
        ),
        BadgeDefinition(
            key: .perfectWeek, name: "Perfect Week", description: "7 days hitting your calorie goal. Flawless week.",
            iconName: "star.fill", category: .bodyProgress, requirement: "7 day calorie goal streak", imageName: "badge_perfectWeek"
        ),
        BadgeDefinition(
            key: .hydrationHero, name: "Hydration Hero", description: "Hit your water goal. Stay hydrated, stay strong.",
            iconName: "drop.fill", category: .bodyProgress, requirement: "Hit daily water goal", imageName: "badge_hydrationHero"
        ),

        // MARK: Social Badges
        BadgeDefinition(
            key: .socialButterfly, name: "Social Butterfly", description: "You added your first friend. Fitness is better together.",
            iconName: "person.2.fill", category: .social, requirement: "Add 1 friend", imageName: "badge_socialButterfly"
        ),
        BadgeDefinition(
            key: .teamPlayer, name: "Team Player", description: "Joined a group challenge. Stronger together.",
            iconName: "handshake.fill", category: .social, requirement: "Join a challenge", imageName: "badge_teamPlayer"
        ),
        BadgeDefinition(
            key: .influencer, name: "Influencer", description: "Shared your progress with the world.",
            iconName: "square.and.arrow.up.fill", category: .social, requirement: "Share a badge", imageName: "badge_influencer"
        ),
    ]
}
