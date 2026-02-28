import Foundation
import SwiftData

@MainActor
class WorkoutPlannerViewModel: ObservableObject {
    // Survey state
    @Published var selectedGoal: String = ""
    @Published var selectedExperience: String = ""
    @Published var daysPerWeek: Int = 4
    @Published var sessionLength: String = "45-60 min"
    @Published var selectedEquipment: Set<String> = []

    // Generation state
    @Published var isGenerating = false
    @Published var generatedPlan: ClaudeService.GeneratedWorkoutPlan?
    @Published var errorMessage: String?
    @Published var planSaved = false

    // Refinement state
    @Published var refinementInput: String = ""
    @Published var isRefining = false
    var conversationHistory: [ClaudeService.ConversationMessage] = []

    let goals = ["Build Muscle", "Lose Fat", "Get Stronger", "General Fitness"]
    let experienceLevels = ["Beginner", "Intermediate", "Advanced"]
    let sessionLengths = ["30 min", "45-60 min", "60-90 min", "90+ min"]
    let equipmentOptions = ["Barbell", "Dumbbells", "Machines", "Cables", "Bodyweight", "Kettlebell", "Resistance Bands"]

    func generatePlan(userStats: (height: Double?, weight: Double?, age: Int?)) async {
        isGenerating = true
        errorMessage = nil

        do {
            generatedPlan = try await ClaudeService.shared.generateWorkoutPlan(
                goal: selectedGoal,
                experience: selectedExperience,
                daysPerWeek: daysPerWeek,
                sessionLength: sessionLength,
                equipment: Array(selectedEquipment),
                userStats: userStats
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isGenerating = false
    }

    func savePlan(context: ModelContext) {
        guard let plan = generatedPlan else { return }

        for routine in plan.routines {
            let workoutRoutine = WorkoutRoutine(
                name: routine.name,
                exerciseNames: routine.exercises,
                defaultSets: routine.setsPerExercise
            )
            workoutRoutine.notes = routine.notes
            context.insert(workoutRoutine)
        }

        try? context.save()
        planSaved = true
    }

    func refinePlan() async {
        guard let currentPlan = generatedPlan, !refinementInput.isEmpty else { return }
        isRefining = true
        errorMessage = nil

        let request = refinementInput

        do {
            let refined = try await ClaudeService.shared.refineWorkoutPlan(
                currentPlan: currentPlan,
                refinement: request,
                history: conversationHistory
            )
            conversationHistory.append(ClaudeService.ConversationMessage(role: "user", content: request))
            conversationHistory.append(ClaudeService.ConversationMessage(role: "assistant", content: "Plan updated."))
            generatedPlan = refined
            refinementInput = ""
        } catch {
            errorMessage = error.localizedDescription
        }

        isRefining = false
    }

    var canGenerate: Bool {
        !selectedGoal.isEmpty && !selectedExperience.isEmpty && !selectedEquipment.isEmpty
    }
}
