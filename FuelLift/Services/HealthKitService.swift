import Foundation
import HealthKit

final class HealthKitService {
    static let shared = HealthKitService()
    private let store = HKHealthStore()

    private init() {}

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    // MARK: - Authorization

    func requestAuthorization() async throws {
        guard isAvailable else { return }

        let readTypes: Set<HKObjectType> = [
            HKQuantityType(.stepCount),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.basalEnergyBurned),
            HKQuantityType(.heartRate),
            HKQuantityType(.bodyMass)
        ]

        let writeTypes: Set<HKSampleType> = [
            HKQuantityType(.dietaryEnergyConsumed),
            HKQuantityType(.dietaryProtein),
            HKQuantityType(.dietaryCarbohydrates),
            HKQuantityType(.dietaryFatTotal),
            HKQuantityType(.bodyMass),
            HKWorkoutType.workoutType()
        ]

        try await store.requestAuthorization(toShare: writeTypes, read: readTypes)
    }

    // MARK: - Read: Steps

    func fetchTodaySteps() async throws -> Int {
        let stepType = HKQuantityType(.stepCount)
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date())
        let descriptor = HKStatisticsQueryDescriptor(
            predicate: .init(quantityType: stepType, predicate: predicate),
            options: .cumulativeSum
        )
        let result = try await descriptor.result(for: store)
        return Int(result?.sumQuantity()?.doubleValue(for: .count()) ?? 0)
    }

    // MARK: - Read: Active Calories Burned

    func fetchTodayActiveCalories() async throws -> Int {
        let type = HKQuantityType(.activeEnergyBurned)
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date())
        let descriptor = HKStatisticsQueryDescriptor(
            predicate: .init(quantityType: type, predicate: predicate),
            options: .cumulativeSum
        )
        let result = try await descriptor.result(for: store)
        return Int(result?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0)
    }

    // MARK: - Write: Dietary Energy

    func logCalories(_ calories: Int, protein: Double, carbs: Double, fat: Double, date: Date) async throws {
        let samples: [HKQuantitySample] = [
            HKQuantitySample(
                type: HKQuantityType(.dietaryEnergyConsumed),
                quantity: HKQuantity(unit: .kilocalorie(), doubleValue: Double(calories)),
                start: date, end: date
            ),
            HKQuantitySample(
                type: HKQuantityType(.dietaryProtein),
                quantity: HKQuantity(unit: .gram(), doubleValue: protein),
                start: date, end: date
            ),
            HKQuantitySample(
                type: HKQuantityType(.dietaryCarbohydrates),
                quantity: HKQuantity(unit: .gram(), doubleValue: carbs),
                start: date, end: date
            ),
            HKQuantitySample(
                type: HKQuantityType(.dietaryFatTotal),
                quantity: HKQuantity(unit: .gram(), doubleValue: fat),
                start: date, end: date
            )
        ]

        for sample in samples {
            try await store.save(sample)
        }
    }

    // MARK: - Write: Body Weight

    func logWeight(kg: Double, date: Date = Date()) async throws {
        let sample = HKQuantitySample(
            type: HKQuantityType(.bodyMass),
            quantity: HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: kg),
            start: date, end: date
        )
        try await store.save(sample)
    }

    // MARK: - Write: Workout

    func logWorkout(name: String, durationSeconds: Int, caloriesBurned: Int, date: Date) async throws {
        let workout = HKWorkout(
            activityType: .traditionalStrengthTraining,
            start: date.addingTimeInterval(-Double(durationSeconds)),
            end: date,
            workoutEvents: nil,
            totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: Double(caloriesBurned)),
            totalDistance: nil,
            metadata: [HKMetadataKeyWorkoutBrandName: "FuelLift", "name": name]
        )
        try await store.save(workout)
    }
}
