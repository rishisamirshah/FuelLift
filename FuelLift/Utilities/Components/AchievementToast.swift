import SwiftUI
import UIKit

struct AchievementToast: View {
    let badge: Badge
    let onDismiss: () -> Void

    @State private var isVisible = false

    private var definition: BadgeDefinition? {
        BadgeDefinition.all.first { $0.key.rawValue == badge.key }
    }

    var body: some View {
        if isVisible {
            HStack(spacing: Theme.spacingMD) {
                if let def = definition, def.hasCustomImage, let imgName = def.imageName {
                    Image(imgName)
                        .resizable()
                        .renderingMode(.original)
                        .interpolation(.none)
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: badge.iconName)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.appBadgeEarned)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Badge Earned")
                        .font(.system(size: Theme.captionSize, weight: .medium))
                        .foregroundStyle(Color.appTextSecondary)

                    Text(badge.name)
                        .font(.system(size: Theme.bodySize, weight: .semibold))
                        .foregroundStyle(Color.appTextPrimary)
                }

                Spacer()

                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.appTextTertiary)
                    .onTapGesture { dismissToast() }
            }
            .padding(Theme.spacingLG)
            .background(Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
            .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
            .padding(.horizontal, Theme.spacingLG)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    private func dismissToast() {
        withAnimation(.easeOut(duration: 0.3)) {
            isVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }

    func onAppearAction() -> some View {
        self.onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isVisible = true
            }
            // Auto-dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                dismissToast()
            }
        }
    }
}

// MARK: - View Modifier for easy use

struct AchievementToastModifier: ViewModifier {
    let badge: Badge?
    let onDismiss: () -> Void

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            if let badge {
                AchievementToast(badge: badge, onDismiss: onDismiss)
                    .onAppearAction()
                    .padding(.top, Theme.spacingSM)
            }
        }
    }
}

extension View {
    func achievementToast(badge: Badge?, onDismiss: @escaping () -> Void) -> some View {
        modifier(AchievementToastModifier(badge: badge, onDismiss: onDismiss))
    }
}
