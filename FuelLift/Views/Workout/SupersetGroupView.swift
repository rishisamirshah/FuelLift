import SwiftUI

struct SupersetGroupView: View {
    let exerciseNames: [String]
    let sets: [[WorkoutSetData]]
    let onToggleSuperset: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            // Superset header
            HStack(spacing: Theme.spacingSM) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundStyle(Color.appAccent)
                Text("Superset")
                    .font(.system(size: Theme.captionSize, weight: .bold))
                    .foregroundStyle(Color.appAccent)

                Spacer()

                Button("Unlink", action: onToggleSuperset)
                    .font(.system(size: Theme.captionSize))
                    .foregroundStyle(Color.appTextSecondary)
            }

            ForEach(exerciseNames.indices, id: \.self) { index in
                VStack(alignment: .leading, spacing: Theme.spacingSM) {
                    Text(exerciseNames[index])
                        .font(.system(size: Theme.bodySize, weight: .bold))
                        .foregroundStyle(Color.appTextPrimary)

                    if index < sets.count {
                        // Column headers
                        HStack(spacing: 0) {
                            Text("SET")
                                .frame(width: 40, alignment: .leading)
                            Spacer()
                            Text("LBS")
                                .frame(width: 80, alignment: .trailing)
                            Text("REPS")
                                .frame(width: 50, alignment: .trailing)
                        }
                        .font(.system(size: Theme.miniSize, weight: .bold))
                        .foregroundStyle(Color.appTextTertiary)

                        ForEach(sets[index].indices, id: \.self) { setIndex in
                            let set = sets[index][setIndex]
                            HStack(spacing: 0) {
                                Text("\(setIndex + 1)")
                                    .font(.system(size: Theme.captionSize))
                                    .foregroundStyle(Color.appTextSecondary)
                                    .frame(width: 40, alignment: .leading)

                                Spacer()

                                Text("\(Int(set.weight)) lb")
                                    .font(.system(size: Theme.captionSize))
                                    .foregroundStyle(Color.appTextPrimary)
                                    .frame(width: 80, alignment: .trailing)

                                Text("× \(set.reps)")
                                    .font(.system(size: Theme.captionSize, weight: .bold))
                                    .foregroundStyle(Color.appTextPrimary)
                                    .frame(width: 50, alignment: .trailing)
                            }
                            .padding(.vertical, Theme.spacingXS)
                        }
                    }
                }

                if index < exerciseNames.count - 1 {
                    Divider()
                        .padding(.vertical, Theme.spacingXS)
                }
            }
        }
        .cardStyle()
    }
}
