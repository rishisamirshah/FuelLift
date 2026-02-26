import SwiftUI
import SwiftData

struct ExerciseDetailView: View {
    let exercise: ExerciseDefinition
    @Environment(\.modelContext) private var modelContext

    @State private var prHistory: [(date: Date, e1rm: Double)] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label(exercise.muscleGroup, systemImage: "figure.strengthtraining.traditional")
                        Label(exercise.equipment, systemImage: "dumbbell")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                // Instructions
                VStack(alignment: .leading, spacing: 8) {
                    Text("How To")
                        .font(.headline)
                    Text(exercise.instructions)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // PR History
                VStack(alignment: .leading, spacing: 8) {
                    Text("PR History")
                        .font(.headline)

                    if prHistory.isEmpty {
                        Text("No sets recorded yet for this exercise.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(prHistory, id: \.date) { entry in
                            HStack {
                                Text(entry.date.shortFormatted)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(entry.e1rm.oneDecimal) kg (est. 1RM)")
                                    .font(.subheadline.bold())
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(exercise.name)
        .onAppear { loadHistory() }
    }

    private func loadHistory() {
        let name = exercise.name
        let descriptor = FetchDescriptor<ExerciseSet>(
            predicate: #Predicate { $0.exerciseName == name && $0.isCompleted && !$0.isWarmup },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        guard let sets = try? modelContext.fetch(descriptor) else { return }

        // Group by day, take best e1RM per day
        var bestByDay: [Date: Double] = [:]
        for set in sets {
            let day = set.timestamp.startOfDay
            let e1rm = set.estimated1RM
            if e1rm > (bestByDay[day] ?? 0) {
                bestByDay[day] = e1rm
            }
        }
        prHistory = bestByDay.sorted(by: { $0.key > $1.key }).map { ($0.key, $0.value) }
    }
}
