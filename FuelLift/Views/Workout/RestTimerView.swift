import SwiftUI

struct RestTimerView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var initialRestTime: Int = 90

    private var progress: Double {
        guard initialRestTime > 0 else { return 0 }
        return Double(viewModel.restTimeRemaining) / Double(initialRestTime)
    }

    var body: some View {
        VStack(spacing: Theme.spacingXL) {
            // Header
            HStack {
                Text("Rest Timer")
                    .font(.system(size: Theme.subheadlineSize, weight: .bold))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Button {
                    viewModel.stopRestTimer()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.appTextTertiary)
                }
            }

            // Circular progress ring with time
            ZStack {
                Circle()
                    .stroke(Color.appCardSecondary, lineWidth: 8)
                    .frame(width: 160, height: 160)

                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(
                        viewModel.restTimeRemaining <= 10 ? Color.red : Color.appAccent,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: viewModel.restTimeRemaining)

                Text(viewModel.restFormatted)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundStyle(viewModel.restTimeRemaining <= 10 ? .red : Color.appTextPrimary)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: viewModel.restTimeRemaining)
            }

            // Quick presets
            HStack(spacing: Theme.spacingSM) {
                ForEach(AppConstants.restTimerPresets, id: \.self) { seconds in
                    Button {
                        viewModel.startRestTimer(seconds: seconds)
                    } label: {
                        Text(formatPreset(seconds))
                            .font(.system(size: Theme.captionSize, weight: .medium))
                            .foregroundStyle(Color.appTextPrimary)
                            .padding(.horizontal, Theme.spacingMD)
                            .padding(.vertical, Theme.spacingSM)
                            .background(Color.appCardSecondary)
                            .clipShape(Capsule())
                    }
                }
            }

            // Controls
            HStack(spacing: Theme.spacingXXL) {
                Button {
                    viewModel.startRestTimer(seconds: max(viewModel.restTimeRemaining - 15, 0))
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.appTextSecondary)
                }

                Button {
                    viewModel.stopRestTimer()
                } label: {
                    Text("Skip")
                        .font(.system(size: Theme.subheadlineSize, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, Theme.spacingHuge)
                        .padding(.vertical, Theme.spacingMD)
                        .background(Color.appAccent)
                        .clipShape(Capsule())
                }

                Button {
                    viewModel.startRestTimer(seconds: viewModel.restTimeRemaining + 15)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
        .padding(Theme.spacingXXL)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusXL))
        .shadow(color: .black.opacity(0.2), radius: 20)
        .padding(Theme.spacingLG)
        .onAppear {
            initialRestTime = max(viewModel.restTimeRemaining, 90)
        }
        .onChange(of: viewModel.restTimeRemaining) { oldValue, newValue in
            if newValue > oldValue {
                initialRestTime = newValue
            }
        }
    }

    private func formatPreset(_ seconds: Int) -> String {
        if seconds < 60 {
            return "\(seconds)s"
        } else {
            return "\(seconds / 60)m"
        }
    }
}
