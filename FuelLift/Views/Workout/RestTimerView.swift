import SwiftUI

struct RestTimerView: View {
    @ObservedObject var viewModel: WorkoutViewModel

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Rest Timer")
                    .font(.subheadline.bold())
                Spacer()
                Button {
                    viewModel.stopRestTimer()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }

            Text(viewModel.restFormatted)
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundStyle(viewModel.restTimeRemaining <= 10 ? .red : .primary)

            // Quick adjust
            HStack(spacing: 12) {
                ForEach(AppConstants.restTimerPresets, id: \.self) { seconds in
                    Button("\(seconds)s") {
                        viewModel.startRestTimer(seconds: seconds)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }

            HStack(spacing: 20) {
                Button {
                    viewModel.startRestTimer(seconds: max(viewModel.restTimeRemaining - 15, 0))
                } label: {
                    Image(systemName: "minus.circle")
                        .font(.title2)
                }

                Button {
                    viewModel.stopRestTimer()
                } label: {
                    Text("Skip")
                        .font(.headline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .background(.orange)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }

                Button {
                    viewModel.startRestTimer(seconds: viewModel.restTimeRemaining + 15)
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                }
            }
        }
        .padding()
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 10)
        .padding()
    }
}
