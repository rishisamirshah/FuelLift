import SwiftUI

struct WorkoutSummaryCard: View {
    let workout: Workout?

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            HStack {
                Image(systemName: "dumbbell.fill")
                    .foregroundStyle(Color.appAccent)
                Text("Today's Workout")
                    .font(.system(size: Theme.subheadlineSize, weight: .bold))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                if workout != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.appWorkoutGreen)
                }
            }

            if let workout {
                VStack(alignment: .leading, spacing: Theme.spacingSM) {
                    Text(workout.name)
                        .font(.system(size: Theme.headlineSize, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)

                    HStack(spacing: Theme.spacingLG) {
                        workoutStat(icon: "clock", value: workout.durationFormatted)
                        workoutStat(icon: "number", value: "\(workout.totalSets) sets")
                        workoutStat(icon: "scalemass", value: "\(Int(workout.totalVolume)) kg")
                    }

                    if !workout.exerciseNames.isEmpty {
                        Text(workout.exerciseNames.joined(separator: " · "))
                            .font(.system(size: Theme.miniSize))
                            .foregroundStyle(Color.appTextTertiary)
                            .lineLimit(2)
                    }
                }
            } else {
                HStack {
                    Text("No workout logged today")
                        .font(.system(size: Theme.bodySize))
                        .foregroundStyle(Color.appTextSecondary)
                    Spacer()
                    Image(systemName: "arrow.right.circle")
                        .foregroundStyle(Color.appAccent)
                }
            }
        }
        .cardStyle()
    }

    private func workoutStat(icon: String, value: String) -> some View {
        HStack(spacing: Theme.spacingXS) {
            Image(systemName: icon)
                .font(.system(size: Theme.miniSize))
                .foregroundStyle(Color.appTextTertiary)
            Text(value)
                .font(.system(size: Theme.captionSize, weight: .medium))
                .foregroundStyle(Color.appTextSecondary)
        }
    }
}
