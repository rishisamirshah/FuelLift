import SwiftUI

struct FloatingActionButton: View {
    let action: () -> Void
    var pixelIcon: String = "icon_plus"
    var size: CGFloat = 56

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            ZStack {
                Circle()
                    .fill(Color.appAccent)
                    .frame(width: size, height: size)
                    .shadow(color: Color.appAccent.opacity(0.4), radius: 8, y: 4)

                Image(pixelIcon)
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: size * 0.38, height: size * 0.38)
            }
        }
        .buttonStyle(FABButtonStyle())
    }
}

private struct FABButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    ZStack(alignment: .bottomTrailing) {
        Color.appBackground.ignoresSafeArea()

        FloatingActionButton {
            print("FAB tapped")
        }
        .padding(Theme.spacingXL)
    }
}
