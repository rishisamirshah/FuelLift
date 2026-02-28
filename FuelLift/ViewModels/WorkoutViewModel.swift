import SwiftUI
import SwiftData

// MARK: - Workout Completion Data

struct WorkoutCompletionData: Identifiable {
    let id = UUID()
    let workoutName: String
    let duration: String
    let totalVolume: Double
    let totalSets: Int
    let exerciseCount: Int
    let personalRecords: [String]
    let workoutNumber: Int
}

@MainActor
final class WorkoutViewModel: ObservableObject {
    @Published var activeWorkout: Workout?
    @Published var exerciseGroups: [WorkoutExerciseGroup] = []
    @Published var elapsedSeconds: Int = 0
    @Published var isResting = false
    @Published var restTimeRemaining: Int = 0
    @Published var showRestTimer = false
    @Published var newPRs: [String] = []  // exercise names with new PRs
    @Published var completionData: WorkoutCompletionData?

    private var timer: Timer?
    private var restTimer: Timer?

    var isWorkoutActive: Bool { activeWorkout != nil }

    // MARK: - Workout Lifecycle

    func startWorkout(name: String = "Workout", from routine: WorkoutRoutine? = nil) {
        let workout = Workout(name: name)
        activeWorkout = workout

        if let routine {
            exerciseGroups = routine.exerciseNames.map { WorkoutExerciseGroup(exerciseName: $0) }
            // Add default sets
            for i in exerciseGroups.indices {
                var sets: [WorkoutSetData] = []
                for s in 1...routine.defaultSetsPerExercise {
                    sets.append(WorkoutSetData(setNumber: s))
                }
                exerciseGroups[i].sets = sets
            }
        } else {
            exerciseGroups = []
        }

        elapsedSeconds = 0
        startTimer()
    }

    func finishWorkout(context: ModelContext) {
        guard let workout = activeWorkout else { return }

        stopTimer()

        // Capture stats BEFORE clearing state
        let capturedName = workout.name
        let capturedDuration = elapsedFormatted
        let capturedVolume = exerciseGroups.flatMap(\.sets)
            .filter { $0.isCompleted && !$0.isWarmup }
            .reduce(0.0) { $0 + $1.volume }
        let capturedSets = exerciseGroups.flatMap(\.sets)
            .filter { $0.isCompleted && !$0.isWarmup }.count
        let capturedExerciseCount = exerciseGroups.count
        let capturedPRs = newPRs

        // Save workout
        workout.durationSeconds = elapsedSeconds
        workout.isCompleted = true
        workout.encodeExerciseGroups(exerciseGroups)

        context.insert(workout)
        try? context.save()

        // Sync to Firestore
        Task {
            _ = try? await FirestoreService.shared.saveWorkout(workout.toFirestoreData())
        }

        // Save individual sets for PR tracking
        saveSetsForPRTracking(context: context)

        // Count total completed workouts
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.isCompleted }
        )
        let workoutCount = (try? context.fetchCount(descriptor)) ?? 1

        // Set completion data for celebration screen
        completionData = WorkoutCompletionData(
            workoutName: capturedName,
            duration: capturedDuration,
            totalVolume: capturedVolume,
            totalSets: capturedSets,
            exerciseCount: capturedExerciseCount,
            personalRecords: capturedPRs,
            workoutNumber: workoutCount
        )

        // Clear active state
        activeWorkout = nil
        exerciseGroups = []
        newPRs = []
    }

    func dismissCompletion() {
        completionData = nil
    }

    func cancelWorkout() {
        stopTimer()
        stopRestTimer()
        activeWorkout = nil
        exerciseGroups = []
    }

    // MARK: - Exercise Management

    func addExercise(name: String) {
        exerciseGroups.append(WorkoutExerciseGroup(exerciseName: name))
    }

    func removeExercise(at index: Int) {
        guard exerciseGroups.indices.contains(index) else { return }
        exerciseGroups.remove(at: index)
    }

    func addSet(to groupIndex: Int) {
        guard exerciseGroups.indices.contains(groupIndex) else { return }
        let nextNum = exerciseGroups[groupIndex].sets.count + 1
        // Pre-fill with last set's weight/reps
        let lastSet = exerciseGroups[groupIndex].sets.last
        exerciseGroups[groupIndex].sets.append(
            WorkoutSetData(
                setNumber: nextNum,
                weight: lastSet?.weight ?? 0,
                reps: lastSet?.reps ?? 0
            )
        )
    }

    func removeSet(from groupIndex: Int, at setIndex: Int) {
        guard exerciseGroups.indices.contains(groupIndex),
              exerciseGroups[groupIndex].sets.indices.contains(setIndex) else { return }
        exerciseGroups[groupIndex].sets.remove(at: setIndex)
    }

    func completeSet(groupIndex: Int, setIndex: Int, context: ModelContext) {
        guard exerciseGroups.indices.contains(groupIndex),
              exerciseGroups[groupIndex].sets.indices.contains(setIndex) else { return }

        exerciseGroups[groupIndex].sets[setIndex].isCompleted = true

        // Check for PR
        let set = exerciseGroups[groupIndex].sets[setIndex]
        let exerciseName = exerciseGroups[groupIndex].exerciseName
        checkForPR(exerciseName: exerciseName, set: set, context: context, groupIndex: groupIndex, setIndex: setIndex)

        // Start rest timer
        startRestTimer(seconds: 90)
    }

    // MARK: - PR Detection

    private func checkForPR(exerciseName: String, set: WorkoutSetData, context: ModelContext, groupIndex: Int, setIndex: Int) {
        let descriptor = FetchDescriptor<ExerciseSet>(
            predicate: #Predicate { s in
                s.exerciseName == exerciseName && s.isCompleted && !s.isWarmup
            },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )

        guard let previousSets = try? context.fetch(descriptor) else { return }

        let currentE1RM = set.estimated1RM
        let bestPrevious = previousSets.map(\.estimated1RM).max() ?? 0

        if currentE1RM > bestPrevious && currentE1RM > 0 {
            exerciseGroups[groupIndex].sets[setIndex].isPersonalRecord = true
            if !newPRs.contains(exerciseName) {
                newPRs.append(exerciseName)
            }
        }
    }

    private func saveSetsForPRTracking(context: ModelContext) {
        for group in exerciseGroups {
            for setData in group.sets where setData.isCompleted && !setData.isWarmup {
                let exerciseSet = ExerciseSet(
                    exerciseName: group.exerciseName,
                    setNumber: setData.setNumber,
                    weight: setData.weight,
                    reps: setData.reps,
                    rpe: setData.rpe,
                    isWarmup: false
                )
                exerciseSet.isCompleted = true
                exerciseSet.isPersonalRecord = setData.isPersonalRecord
                context.insert(exerciseSet)
            }
        }
        try? context.save()
    }

    // MARK: - Warm-up Calculator

    func warmupSets(for workingWeight: Double) -> [(weight: Double, reps: Int)] {
        guard workingWeight > 20 else { return [] }
        return [
            (workingWeight * 0.4, 10),
            (workingWeight * 0.6, 6),
            (workingWeight * 0.8, 3),
        ]
    }

    // MARK: - Timers

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.elapsedSeconds += 1
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func startRestTimer(seconds: Int) {
        stopRestTimer()
        restTimeRemaining = seconds
        showRestTimer = true
        isResting = true

        restTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                if self.restTimeRemaining > 0 {
                    self.restTimeRemaining -= 1
                } else {
                    self.stopRestTimer()
                }
            }
        }
    }

    func stopRestTimer() {
        restTimer?.invalidate()
        restTimer = nil
        isResting = false
        showRestTimer = false
    }

    var elapsedFormatted: String {
        let m = elapsedSeconds / 60
        let s = elapsedSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    var restFormatted: String {
        let m = restTimeRemaining / 60
        let s = restTimeRemaining % 60
        return String(format: "%d:%02d", m, s)
    }
}
