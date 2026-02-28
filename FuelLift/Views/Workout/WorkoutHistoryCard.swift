import SwiftUI

// MARK: - Workout History Card

struct WorkoutHistoryCard: View {
    let workout: Workout

    private var exerciseGroups: [WorkoutExerciseGroup] {
        workout.decodeExerciseGroups()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: Theme.spacingXS) {
                    Text(workout.name)
                        .font(.system(size: Theme.subheadlineSize, weight: .bold))
                        .foregroundStyle(Color.appTextPrimary)

                    Text(workout.date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                        .font(.system(size: Theme.captionSize))
                        .foregroundStyle(Color.appTextSecondary)
                }

                Spacer()

                Menu {
                    Button("Edit", systemImage: "pencil") {}
                    Button("Delete", systemImage: "trash", role: .destructive) {}
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Color.appTextSecondary)
                        .padding(Theme.spacingSM)
                }
            }

            // Stats row
            HStack(spacing: Theme.spacingLG) {
                Label(workout.durationFormatted, systemImage: "clock")

                Label("\(Int(workout.totalVolume).formattedWithComma) lb", systemImage: "scalemass")

                let prCount = exerciseGroups.flatMap(\.sets).filter(\.isPersonalRecord).count
                if prCount > 0 {
                    Label("\(prCount) PRs", systemImage: "trophy.fill")
                        .foregroundStyle(Color.appPRWeight)
                } else {
                    Label("0 PRs", systemImage: "trophy")
                }
            }
            .font(.system(size: Theme.captionSize))
            .foregroundStyle(Color.appTextSecondary)

            if !exerciseGroups.isEmpty {
                Divider()

                // Column headers
                HStack {
                    Text("Exercise")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Best Set")
                        .frame(width: 120, alignment: .trailing)
                }
                .font(.system(size: Theme.captionSize, weight: .semibold))
                .foregroundStyle(Color.appTextTertiary)

                ForEach(exerciseGroups.prefix(5)) { group in
                    exerciseRow(group)
                }

                if exerciseGroups.count > 5 {
                    Text("+\(exerciseGroups.count - 5) more")
                        .font(.system(size: Theme.captionSize))
                        .foregroundStyle(Color.appTextTertiary)
                }
            }
        }
        .cardStyle()
    }

    private func exerciseRow(_ group: WorkoutExerciseGroup) -> some View {
        let completedSets = group.sets.filter { $0.isCompleted && !$0.isWarmup }
        let bestSet = completedSets.max(by: { $0.estimated1RM < $1.estimated1RM })
        let hasPR = group.sets.contains(where: \.isPersonalRecord)

        return HStack(spacing: Theme.spacingSM) {
            Text("\(completedSets.count) × \(group.exerciseName)")
                .font(.system(size: Theme.captionSize))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)

            if hasPR {
                PRBadge(type: .oneRM)
            }

            Spacer()

            if let best = bestSet {
                Text("\(Int(best.weight)) lb × \(best.reps)")
                    .font(.system(size: Theme.captionSize))
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
    }
}

// MARK: - PR Badge

enum PRType {
    case oneRM, volume, weight

    var label: String {
        switch self {
        case .oneRM: return "1RM"
        case .volume: return "VOL"
        case .weight: return "WEIGHT"
        }
    }

    var color: Color {
        switch self {
        case .oneRM: return .appPR1RM
        case .volume: return .appPRVolume
        case .weight: return .appPRWeight
        }
    }
}

struct PRBadge: View {
    let type: PRType

    var body: some View {
        Text(type.label)
            .font(.caption2)
            .bold()
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(type.color)
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }
}
