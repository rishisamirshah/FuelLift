import SwiftUI

struct WorkoutSummaryCard: View {
    let workout: Workout?

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            HStack {
                Image("icon_dumbbell")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 20, height: 20)
                Text("Today's Workout")
                    .font(.system(size: Theme.subheadlineSize, weight: .bold))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                if workout != nil {
                    Image("icon_checkmark_circle")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 20, height: 20)
                }
            }

            if let workout {
                VStack(alignment: .leading, spacing: Theme.spacingSM) {
                    Text(workout.name)
                        .font(.system(size: Theme.headlineSize, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)

                    HStack(spacing: Theme.spacingLG) {
                        workoutStat(iconName: "icon_clock", value: workout.durationFormatted)
                        workoutStat(iconName: "icon_scale", value: "\(workout.totalSets) sets")
                        workoutStat(iconName: "icon_scale", value: "\(Int(workout.totalVolume)) kg")
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
                    Image("icon_arrow_right_circle")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 20, height: 20)
                }
            }
        }
        .cardStyle()
    }

    private func workoutStat(iconName: String, value: String) -> some View {
        HStack(spacing: Theme.spacingXS) {
            Image(iconName)
                .resizable()
                .renderingMode(.original)
                .frame(width: 14, height: 14)
            Text(value)
                .font(.system(size: Theme.captionSize, weight: .medium))
                .foregroundStyle(Color.appTextSecondary)
        }
    }
}
