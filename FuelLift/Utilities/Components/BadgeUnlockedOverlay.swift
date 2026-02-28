import SwiftUI
import ConfettiSwiftUI

struct BadgeUnlockedOverlay: View {
    let badge: Badge
    let onDismiss: () -> Void

    @State private var iconScale: CGFloat = 0.3
    @State private var textOpacity: Double = 0.0
    @State private var confettiCounter: Int = 0

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: Theme.spacingXXL) {
                Spacer()

                // Badge icon with scale animation
                ZStack {
                    Circle()
                        .fill(Color.appBadgeEarned.opacity(0.2))
                        .frame(width: 160, height: 160)

                    Image(systemName: badge.iconName)
                        .font(.system(size: 72))
                        .foregroundStyle(Color.appBadgeEarned)
                }
                .scaleEffect(iconScale)
                .confettiCannon(counter: $confettiCounter, num: 50, radius: 300)

                // Badge name + unlocked text
                VStack(spacing: Theme.spacingSM) {
                    Text(badge.name)
                        .font(.system(size: Theme.titleSize, weight: .bold))
                        .foregroundStyle(Color.white)

                    Text("Unlocked!")
                        .font(.system(size: Theme.headlineSize, weight: .medium))
                        .foregroundStyle(Color.appBadgeEarned)
                }
                .opacity(textOpacity)

                Text(badge.requirement)
                    .font(.system(size: Theme.bodySize))
                    .foregroundStyle(Color.white.opacity(0.7))
                    .opacity(textOpacity)

                Spacer()

                Text("Tap to dismiss")
                    .font(.system(size: Theme.captionSize))
                    .foregroundStyle(Color.white.opacity(0.4))
                    .opacity(textOpacity)
                    .padding(.bottom, Theme.spacingHuge)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                iconScale = 1.0
            }
            withAnimation(.easeIn(duration: 0.4).delay(0.3)) {
                textOpacity = 1.0
            }
            confettiCounter += 1

            // Auto-dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                onDismiss()
            }
        }
    }
}
