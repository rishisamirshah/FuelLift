Add new exercises to FuelLift's exercise library.

The user will describe the exercise(s). For example: `/add-exercise "Bulgarian Split Squat" - legs, compound`

Steps:
1. Read `FuelLift/FuelLift/Models/Exercise.swift` to understand the Exercise model structure (name, bodyPart, category, equipment, instructions)
2. Read the existing exercise library data to check for duplicates
3. Add the new exercise(s) with proper categorization:
   - Body part: Chest, Back, Shoulders, Arms, Legs, Core, Full Body
   - Category: Compound or Isolation
   - Equipment: Barbell, Dumbbell, Machine, Cable, Bodyweight, Band, Other
   - Include brief exercise instructions/form cues

4. If adding many exercises, organize them by body part grouping
5. Verify the exercise appears in the ExerciseLibraryView filter system

The app currently has 45+ predefined exercises. The exercise library is displayed in `FuelLift/FuelLift/Views/Workout/ExerciseLibraryView.swift` with body part filtering (FilterPills component).

Users can also create custom exercises in-app, but predefined ones appear for all users.
