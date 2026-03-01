import SwiftUI
import ConfettiSwiftUI

struct WorkoutCompletionView: View {
    let data: WorkoutCompletionData
    let onDismiss: () -> Void

    @State private var trophyScale: CGFloat = 0.3
    @State private var titleOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = 20
    @State private var subtitleOpacity: Double = 0.0
    @State private var subtitleOffset: CGFloat = 20
    @State private var statsOpacity: Double = 0.0
    @State private var statsOffset: CGFloat = 20
    @State private var prOpacity: Double = 0.0
    @State private var prOffset: CGFloat = 20
    @State private var buttonOpacity: Double = 0.0
    @State private var buttonOffset: CGFloat = 20
    @State private var confettiCounter: Int = 0

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingXXL) {
                Spacer(minLength: Theme.spacingHuge)

                // Trophy icon with spring animation
                ZStack {
                    Circle()
                        .fill(Color.appWorkoutGreen.opacity(0.2))
                        .frame(width: 120, height: 120)

                    Image("icon_trophy")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 72, height: 72)
                }
                .scaleEffect(trophyScale)
                .confettiCannon(counter: $confettiCounter, num: 50, radius: 300)

                // Title + subtitle
                VStack(spacing: Theme.spacingSM) {
                    Text("Workout Complete!")
                        .font(.system(size: Theme.titleSize, weight: .bold))
                        .foregroundStyle(Color.appTextPrimary)

                    Text("That's your \(data.workoutNumber.ordinalString) workout!")
                        .font(.system(size: Theme.subheadlineSize))
                        .foregroundStyle(Color.appTextSecondary)
                }
                .opacity(titleOpacity)
                .offset(y: titleOffset)

                // Stat cards — 2x2 grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: Theme.spacingMD),
                    GridItem(.flexible(), spacing: Theme.spacingMD)
                ], spacing: Theme.spacingMD) {
                    pixelStatCard(iconName: "icon_timer", label: "Duration", value: data.duration)
                    statCard(icon: "figure.strengthtraining.traditional", label: "Exercises", value: "\(data.exerciseCount)")
                    pixelStatCard(iconName: "icon_checkmark_circle", label: "Sets", value: "\(data.totalSets)")
                    pixelStatCard(iconName: "icon_scale", label: "Volume", value: "\(Int(data.totalVolume).formattedWithComma) lb")
                }
                .padding(.horizontal, Theme.spacingLG)
                .opacity(statsOpacity)
                .offset(y: statsOffset)

                // PR section
                if !data.personalRecords.isEmpty {
                    VStack(alignment: .leading, spacing: Theme.spacingMD) {
                        Text("Personal Records")
                            .font(.system(size: Theme.headlineSize, weight: .bold))
                            .foregroundStyle(Color.appTextPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(data.personalRecords, id: \.self) { exercise in
                            HStack(spacing: Theme.spacingSM) {
                                Image("icon_trophy")
                                    .resizable()
                                    .renderingMode(.original)
                                    .frame(width: 20, height: 20)

                                Text(exercise)
                                    .font(.system(size: Theme.bodySize, weight: .semibold))
                                    .foregroundStyle(Color.appTextPrimary)

                                Spacer()

                                PRBadge(type: .oneRM)
                            }
                            .padding(Theme.spacingMD)
                            .background(Color.appPRWeight.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSM))
                        }
                    }
                    .padding(.horizontal, Theme.spacingLG)
                    .opacity(prOpacity)
                    .offset(y: prOffset)
                }

                Spacer(minLength: Theme.spacingLG)

                // Done button
                Button {
                    onDismiss()
                } label: {
                    Text("Done")
                        .font(.system(size: Theme.subheadlineSize, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.spacingLG)
                        .background(Color.appWorkoutGreen)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                }
                .padding(.horizontal, Theme.spacingLG)
                .opacity(buttonOpacity)
                .offset(y: buttonOffset)

                Spacer(minLength: Theme.spacingHuge)
            }
        }
        .screenBackground()
        .onAppear {
            // Trophy spring animation
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                trophyScale = 1.0
            }

            // Confetti
            confettiCounter += 1

            // Staggered entrance animations
            withAnimation(.easeOut(duration: 0.4).delay(0.2)) {
                titleOpacity = 1.0
                titleOffset = 0
            }

            withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                subtitleOpacity = 1.0
                subtitleOffset = 0
            }

            withAnimation(.easeOut(duration: 0.4).delay(0.4)) {
                statsOpacity = 1.0
                statsOffset = 0
            }

            withAnimation(.easeOut(duration: 0.4).delay(0.5)) {
                prOpacity = 1.0
                prOffset = 0
            }

            withAnimation(.easeOut(duration: 0.4).delay(0.6)) {
                buttonOpacity = 1.0
                buttonOffset = 0
            }
        }
    }

    // MARK: - Stat Card

    private func statCard(icon: String, label: String, value: String) -> some View {
        VStack(spacing: Theme.spacingSM) {
            Image(systemName: icon)
                .font(.system(size: Theme.headlineSize))
                .foregroundStyle(Color.appWorkoutGreen)

            Text(value)
                .font(.system(size: Theme.headlineSize, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.system(size: Theme.captionSize))
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingLG)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
    }

    private func pixelStatCard(iconName: String, label: String, value: String) -> some View {
        VStack(spacing: Theme.spacingSM) {
            Image(iconName)
                .resizable()
                .renderingMode(.original)
                .frame(width: 24, height: 24)

            Text(value)
                .font(.system(size: Theme.headlineSize, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.system(size: Theme.captionSize))
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingLG)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
    }
}
