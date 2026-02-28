import Foundation
import SwiftData
import SwiftUI

@Observable
class BadgeViewModel {
    var badges: [Badge] = []
    var newlyEarnedBadge: Badge? = nil
    var showConfetti: Bool = false

    // MARK: - Load & Initialize

    func loadBadges(context: ModelContext) {
        let descriptor = FetchDescriptor<Badge>(sortBy: [SortDescriptor(\.key)])
        badges = (try? context.fetch(descriptor)) ?? []
    }

    func initializeBadgesIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Badge>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0

        guard existingCount == 0 else {
            loadBadges(context: context)
            return
        }

        for def in BadgeDefinition.all {
            let badge = Badge(
                key: def.key.rawValue,
                name: def.name,
                badgeDescription: def.description,
                iconName: def.iconName,
                category: def.category.rawValue,
                requirement: def.requirement
            )
            context.insert(badge)
        }
        try? context.save()
        loadBadges(context: context)
    }

    // MARK: - Badge Counts

    var earnedCount: Int {
        badges.filter(\.isEarned).count
    }

    var totalCount: Int {
        badges.count
    }

    func badges(for category: BadgeCategory) -> [Badge] {
        badges.filter { $0.category == category.rawValue }
    }

    // MARK: - Check Badges

    func checkStreakBadges(currentStreak: Int, context: ModelContext) {
        let thresholds: [(BadgeKey, Int)] = [
            (.rookie, 3),
            (.gettingSerious, 10),
            (.lockedIn, 50),
            (.tripleThreat, 100),
            (.noDaysOff, 365),
            (.immortal, 1000),
        ]
        for (key, threshold) in thresholds where currentStreak >= threshold {
            awardBadge(key: key, context: context)
        }
    }

    func checkMealBadges(mealCount: Int, context: ModelContext) {
        let thresholds: [(BadgeKey, Int)] = [
            (.firstBite, 1),
            (.forkingAround, 5),
            (.nutritionNovice, 20),
            (.missionNutrition, 50),
            (.theLogfather, 500),
            (.calorieCounter, 1000),
        ]
        for (key, threshold) in thresholds where mealCount >= threshold {
            awardBadge(key: key, context: context)
        }
    }

    func checkWorkoutBadges(workoutCount: Int, context: ModelContext) {
        let thresholds: [(BadgeKey, Int)] = [
            (.firstRep, 1),
            (.gymRat, 10),
            (.ironAddict, 50),
            (.beastMode, 100),
            (.legendary, 500),
        ]
        for (key, threshold) in thresholds where workoutCount >= threshold {
            awardBadge(key: key, context: context)
        }
    }

    func checkPRBadges(prCount: Int, totalVolume: Double, context: ModelContext) {
        let prThresholds: [(BadgeKey, Int)] = [
            (.prBreaker, 1),
            (.prMachine, 10),
            (.prMonster, 50),
        ]
        for (key, threshold) in prThresholds where prCount >= threshold {
            awardBadge(key: key, context: context)
        }

        if totalVolume >= 1_000_000 {
            awardBadge(key: .millionPoundClub, context: context)
        }
        if totalVolume >= 100_000 {
            awardBadge(key: .volumeKing, context: context)
        }
    }

    func checkBodyBadges(
        weightLogCount: Int,
        photoCount: Int,
        hitCalorieGoal: Bool,
        calorieGoalStreak: Int,
        hitWaterGoal: Bool,
        context: ModelContext
    ) {
        if weightLogCount >= 1 {
            awardBadge(key: .weighIn, context: context)
        }
        if photoCount >= 1 {
            awardBadge(key: .snapshot, context: context)
        }
        if photoCount >= 10 {
            awardBadge(key: .transformation, context: context)
        }
        if hitCalorieGoal {
            awardBadge(key: .goalCrusher, context: context)
        }
        if calorieGoalStreak >= 7 {
            awardBadge(key: .perfectWeek, context: context)
        }
        if hitWaterGoal {
            awardBadge(key: .hydrationHero, context: context)
        }
    }

    func checkSocialBadges(friendCount: Int, joinedChallenge: Bool, sharedBadge: Bool, context: ModelContext) {
        if friendCount >= 1 {
            awardBadge(key: .socialButterfly, context: context)
        }
        if joinedChallenge {
            awardBadge(key: .teamPlayer, context: context)
        }
        if sharedBadge {
            awardBadge(key: .influencer, context: context)
        }
    }

    // MARK: - Award Badge

    private func awardBadge(key: BadgeKey, context: ModelContext) {
        guard let badge = badges.first(where: { $0.key == key.rawValue }) else { return }
        guard !badge.isEarned else { return }

        badge.earnedDate = Date()
        try? context.save()

        newlyEarnedBadge = badge
        showConfetti = true

        loadBadges(context: context)
    }

    func dismissBadgeOverlay() {
        newlyEarnedBadge = nil
        showConfetti = false
    }
}
