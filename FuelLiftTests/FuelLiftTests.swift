import XCTest
@testable import FuelLift

final class FuelLiftTests: XCTestCase {

    func testNutritionDataDecoding() throws {
        let json = """
        {"name":"Grilled Chicken","calories":350,"protein_g":42.0,"carbs_g":5.0,"fat_g":12.5,"serving_size":"200g"}
        """
        let data = json.data(using: .utf8)!
        let nutrition = try JSONDecoder().decode(NutritionData.self, from: data)

        XCTAssertEqual(nutrition.name, "Grilled Chicken")
        XCTAssertEqual(nutrition.calories, 350)
        XCTAssertEqual(nutrition.proteinG, 42.0)
        XCTAssertEqual(nutrition.carbsG, 5.0)
        XCTAssertEqual(nutrition.fatG, 12.5)
        XCTAssertEqual(nutrition.servingSize, "200g")
    }

    func testExerciseSetEstimated1RM() {
        let set = ExerciseSet(exerciseName: "Bench Press", setNumber: 1, weight: 100, reps: 5)
        // Epley: 100 * (1 + 5/30) = 100 * 1.1667 ≈ 116.67
        XCTAssertEqual(set.estimated1RM, 100 * (1 + 5.0/30.0), accuracy: 0.01)
    }

    func testExerciseSetEstimated1RMSingleRep() {
        let set = ExerciseSet(exerciseName: "Squat", setNumber: 1, weight: 180, reps: 1)
        XCTAssertEqual(set.estimated1RM, 180.0)
    }

    func testExerciseSetVolume() {
        let set = ExerciseSet(exerciseName: "Deadlift", setNumber: 1, weight: 150, reps: 3)
        XCTAssertEqual(set.volume, 450.0)
    }

    func testWorkoutExerciseGroupEncoding() throws {
        var group = WorkoutExerciseGroup(exerciseName: "Bench Press")
        group.sets = [
            WorkoutSetData(setNumber: 1, weight: 80, reps: 8),
            WorkoutSetData(setNumber: 2, weight: 85, reps: 6)
        ]

        let encoded = try JSONEncoder().encode([group])
        let decoded = try JSONDecoder().decode([WorkoutExerciseGroup].self, from: encoded)

        XCTAssertEqual(decoded.count, 1)
        XCTAssertEqual(decoded[0].exerciseName, "Bench Press")
        XCTAssertEqual(decoded[0].sets.count, 2)
        XCTAssertEqual(decoded[0].sets[0].weight, 80)
    }

    func testDefaultExerciseLibraryLoads() {
        let exercises = ExerciseDefinition.defaultExercises
        XCTAssertGreaterThan(exercises.count, 20)

        let muscleGroups = Set(exercises.map(\.muscleGroup))
        XCTAssertTrue(muscleGroups.contains("Chest"))
        XCTAssertTrue(muscleGroups.contains("Back"))
        XCTAssertTrue(muscleGroups.contains("Legs"))
    }

    func testMealTypeAllCases() {
        XCTAssertEqual(MealType.allCases.count, 4)
        XCTAssertEqual(MealType.breakfast.displayName, "Breakfast")
    }

    func testFoodEntryToFirestoreData() {
        let entry = FoodEntry(
            name: "Rice",
            calories: 200,
            proteinG: 4,
            carbsG: 45,
            fatG: 0.5,
            servingSize: "1 cup",
            mealType: "lunch",
            source: "manual"
        )
        let data = entry.toFirestoreData()
        XCTAssertEqual(data["name"] as? String, "Rice")
        XCTAssertEqual(data["calories"] as? Int, 200)
    }
}
