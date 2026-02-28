import SwiftUI

struct StreakBadge: View {
    let count: Int
    var style: StreakStyle = .compact

    enum StreakStyle {
        case compact   // Small pill for top-right corner
        case expanded  // Larger card for progress page
    }

    @State private var isPulsing = false

    var body: some View {
        switch style {
        case .compact:
            compactBadge
        case .expanded:
            expandedBadge
        }
    }

    private var compactBadge: some View {
        HStack(spacing: 4) {
            Text("🔥")
                .font(.system(size: 14))
                .scaleEffect(isPulsing ? 1.15 : 1.0)

            Text("\(count)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.appCardBackground)
        .clipShape(Capsule())
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }

    private var expandedBadge: some View {
        VStack(spacing: Theme.spacingSM) {
            Text("🔥")
                .font(.system(size: 44))
                .scaleEffect(isPulsing ? 1.1 : 1.0)

            Text("\(count)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appStreakColor)

            Text("Day Streak")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingLG)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack {
            Spacer()
            StreakBadge(count: 101, style: .compact)
        }
        .padding()

        StreakBadge(count: 101, style: .expanded)
            .padding()
    }
    .background(Color.appBackground)
}
