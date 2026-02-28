import SwiftUI

struct WorkoutShareView: View {
    let workout: Workout

    @State private var shareImage: UIImage?

    var body: some View {
        VStack(spacing: Theme.spacingLG) {
            // Shareable card
            shareCard
                .padding(.horizontal, Theme.spacingLG)

            HStack(spacing: Theme.spacingLG) {
                ShareLink(item: workoutSummaryText) {
                    Label("Share Text", systemImage: "square.and.arrow.up")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(Theme.spacingMD)
                        .background(Color.appCardBackground)
                        .foregroundStyle(Color.appTextPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                }

                if let image = shareImage {
                    ShareLink(item: Image(uiImage: image), preview: SharePreview("FuelLift Workout", image: Image(uiImage: image))) {
                        Label("Share Image", systemImage: "photo")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(Theme.spacingMD)
                            .background(Color.appAccent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                    }
                }
            }
            .padding(.horizontal, Theme.spacingLG)

            Spacer()
        }
        .padding(.top, Theme.spacingLG)
        .screenBackground()
        .navigationTitle("Share Workout")
        .onAppear {
            renderShareImage()
        }
    }

    private var shareCard: some View {
        VStack(spacing: Theme.spacingMD) {
            // Header
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(Color.appAccent)
                Text("FuelLift")
                    .font(.system(size: Theme.captionSize, weight: .bold))
                    .foregroundStyle(Color.appAccent)
                Spacer()
                Text(workout.date.shortFormatted)
                    .font(.system(size: Theme.captionSize))
                    .foregroundStyle(Color.appTextSecondary)
            }

            Text(workout.name)
                .font(.system(size: Theme.headlineSize, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)

            // Stats row
            HStack(spacing: Theme.spacingXXL) {
                statBlock(value: workout.durationFormatted, label: "Duration")
                statBlock(value: "\(workout.totalSets)", label: "Sets")
                statBlock(value: "\(Int(workout.totalVolume)) kg", label: "Volume")
            }
            .padding(.vertical, Theme.spacingSM)

            if !workout.exerciseNames.isEmpty {
                Divider()
                    .overlay(Color.appCardSecondary)

                VStack(alignment: .leading, spacing: Theme.spacingXS) {
                    ForEach(workout.exerciseNames, id: \.self) { name in
                        HStack(spacing: Theme.spacingSM) {
                            Circle()
                                .fill(Color.appAccent)
                                .frame(width: 4, height: 4)
                            Text(name)
                                .font(.system(size: Theme.captionSize))
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .cardStyle()
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusLG)
                .stroke(Color.appAccent.opacity(0.2), lineWidth: 1)
        )
    }

    private func statBlock(value: String, label: String) -> some View {
        VStack(spacing: Theme.spacingXS) {
            Text(value)
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            Text(label)
                .font(.system(size: Theme.miniSize))
                .foregroundStyle(Color.appTextTertiary)
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
