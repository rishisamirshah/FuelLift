Scaffold a new SwiftData @Model following FuelLift's data model patterns.

The user will provide the model name and fields. For example: `/new-model MealPlan`

Steps:
1. Create the model at `FuelLift/FuelLift/Models/{Name}.swift`:
   - Import Foundation and SwiftData
   - Use `@Model final class` pattern
   - Add `id: UUID = UUID()` as the primary identifier
   - Add `createdAt: Date = Date()` timestamp
   - Include a proper initializer
   - Follow patterns from existing models like `FoodEntry.swift`, `Workout.swift`, `Badge.swift`

2. If the model needs Firestore sync (ask user), add a `toFirestoreData() -> [String: Any]` method and a `static func fromFirestoreData(_ data: [String: Any]) -> {Name}?` factory method, following `FoodEntry.swift` pattern.

3. Register the model in the ModelContainer in `FuelLift/FuelLift/App/FuelLiftApp.swift` — add it to the schema array.

4. If this model needs a list/detail view, suggest running `/new-view` next.

Existing models for reference: UserProfile, FoodEntry, Workout, Exercise, ExerciseSet, Badge, BodyMetric, WaterEntry, Restaurant, MenuItem, MenuItemScore.

All models use SwiftData @Model (iOS 17+), NOT Core Data.
