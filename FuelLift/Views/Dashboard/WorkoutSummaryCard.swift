import SwiftUI

struct WorkoutSummaryCard: View {
    let workout: Workout?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "dumbbell.fill")
                    .foregroundStyle(.orange)
                Text("Today's Workout")
                    .font(.subheadline.bold())
                Spacer()
            }

            if let workout {
                VStack(alignment: .leading, spacing: 6) {
                    Text(workout.name)
                        .font(.headline)

                    HStack(spacing: 16) {
                        Label(workout.durationFormatted, systemImage: "clock")
                        Label("\(workout.totalSets) sets", systemImage: "number")
                        Label("\(Int(workout.totalVolume)) kg", systemImage: "scalemass")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    if !workout.exerciseNames.isEmpty {
                        Text(workout.exerciseNames.joined(separator: " · "))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .lineLimit(2)
                    }
                }
            } else {
                HStack {
                    Text("No workout logged today")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: "arrow.right.circle")
                        .foregroundStyle(.orange)
                }
            }
        }
        .cardStyle()
    }
}
