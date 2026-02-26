import SwiftUI

struct WorkoutShareView: View {
    let workout: Workout

    @State private var shareImage: UIImage?

    var body: some View {
        VStack(spacing: 16) {
            // Shareable card
            shareCard
                .padding(.horizontal)

            HStack(spacing: 16) {
                ShareLink(item: workoutSummaryText) {
                    Label("Share Text", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                if let image = shareImage {
                    ShareLink(item: Image(uiImage: image), preview: SharePreview("FuelLift Workout", image: Image(uiImage: image))) {
                        Label("Share Image", systemImage: "photo")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.orange)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Share Workout")
        .onAppear {
            renderShareImage()
        }
    }

    private var shareCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text("FuelLift")
                    .font(.caption.bold())
                    .foregroundStyle(.orange)
                Spacer()
                Text(workout.date.shortFormatted)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(workout.name)
                .font(.title2.bold())

            HStack(spacing: 24) {
                statBlock(value: workout.durationFormatted, label: "Duration")
                statBlock(value: "\(workout.totalSets)", label: "Sets")
                statBlock(value: "\(Int(workout.totalVolume)) kg", label: "Volume")
            }

            if !workout.exerciseNames.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(workout.exerciseNames, id: \.self) { name in
                        Text("- \(name)")
                            .font(.caption)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }

    private func statBlock(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.headline)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
    }

    private var workoutSummaryText: String {
        """
        \(workout.name) - \(workout.date.shortFormatted)
        Duration: \(workout.durationFormatted) | Sets: \(workout.totalSets) | Volume: \(Int(workout.totalVolume)) kg
        Exercises: \(workout.exerciseNames.joined(separator: ", "))

        Tracked with FuelLift
        """
    }

    @MainActor
    private func renderShareImage() {
        let renderer = ImageRenderer(content: shareCard.frame(width: 350))
        renderer.scale = 3
        shareImage = renderer.uiImage
    }
}
