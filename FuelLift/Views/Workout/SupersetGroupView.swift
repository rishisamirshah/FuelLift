import SwiftUI

struct SupersetGroupView: View {
    let exerciseNames: [String]
    let sets: [[WorkoutSetData]]
    let onToggleSuperset: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundStyle(.orange)
                Text("Superset")
                    .font(.caption.bold())
                    .foregroundStyle(.orange)
                Spacer()
                Button("Unlink", action: onToggleSuperset)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(exerciseNames.indices, id: \.self) { index in
                VStack(alignment: .leading, spacing: 4) {
                    Text(exerciseNames[index])
                        .font(.subheadline.bold())

                    if index < sets.count {
                        ForEach(sets[index].indices, id: \.self) { setIndex in
                            HStack {
                                Text("Set \(setIndex + 1)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 50)
                                Spacer()
                                Text("\(sets[index][setIndex].weight, specifier: "%.1f") kg")
                                    .font(.caption)
                                Text("x \(sets[index][setIndex].reps)")
                                    .font(.caption.bold())
                            }
                        }
                    }
                }

                if index < exerciseNames.count - 1 {
                    Divider()
                }
            }
        }
        .cardStyle()
    }
}
