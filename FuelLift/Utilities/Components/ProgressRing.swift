import SwiftUI
import UIKit

struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let gradient: LinearGradient
    let size: CGFloat
    var trackColor: Color = Color(UIColor.systemGray5)

    @State private var animatedProgress: Double = 0

    private var clampedProgress: Double {
        min(max(animatedProgress, 0), 1)
    }

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)

            // Progress
            Circle()
                .trim(from: 0, to: clampedProgress)
                .stroke(gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Calorie Ring with Center Label

struct CalorieRing: View {
    let caloriesEaten: Int
    let calorieGoal: Int
    let size: CGFloat

    @State private var displayedCalories: Int = 0

    private var progress: Double {
        guard calorieGoal > 0 else { return 0 }
        return Double(caloriesEaten) / Double(calorieGoal)
    }

    private var remaining: Int {
        max(calorieGoal - caloriesEaten, 0)
    }

    var body: some View {
        ZStack {
            ProgressRing(
                progress: progress,
                lineWidth: Theme.ringLineWidth,
                gradient: .calorieRingGradient,
                size: size
            )

            VStack(spacing: 2) {
                Text("\(remaining)")
                    .font(.system(size: size * 0.22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)
                    .contentTransition(.numericText())

                Text("remaining")
                    .font(.system(size: size * 0.09, weight: .medium))
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
    }
}

// MARK: - Macro Ring with Label

struct MacroRing: View {
    let label: String
    let current: Double
    let goal: Double
    let gradient: LinearGradient
    let emoji: String
    let size: CGFloat

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return current / goal
    }

    /// Maps macro emoji to a local pixel art asset, falling back to the emoji text.
    @ViewBuilder
    private var macroIcon: some View {
        let assetName: String? = switch emoji {
        case "\u{1F969}": "icon_meat_protein"   // 🥩
        case "\u{1F35E}": "icon_bread_carbs"    // 🍞
        case "\u{1F9C8}": "icon_butter_fat"     // 🧈
        default: nil
        }

        if let assetName, UIImage(named: assetName) != nil {
            Image(assetName)
                .resizable()
                .interpolation(.none)
                .aspectRatio(contentMode: .fit)
        } else {
            Text(emoji)
                .font(.system(size: size * 0.35))
        }
    }

    var body: some View {
        VStack(spacing: Theme.spacingSM) {
            ZStack {
                ProgressRing(
                    progress: progress,
                    lineWidth: Theme.macroRingLineWidth,
                    gradient: gradient,
                    size: size
                )

                macroIcon
                    .frame(width: size * 0.45, height: size * 0.45)
            }

            VStack(spacing: 2) {
                Text("\(Int(current))")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary) +
                Text("/\(Int(goal))g")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.appTextSecondary)

                Text(label)
                    .font(.caption2)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        CalorieRing(caloriesEaten: 1200, calorieGoal: 2315, size: 120)

        HStack(spacing: 30) {
            MacroRing(label: "Protein", current: 80, goal: 187, gradient: .proteinRingGradient, emoji: "🥩", size: 56)
            MacroRing(label: "Carbs", current: 120, goal: 247, gradient: .carbsRingGradient, emoji: "🍞", size: 56)
            MacroRing(label: "Fat", current: 30, goal: 84, gradient: .fatRingGradient, emoji: "🧈", size: 56)
        }
    }
    .padding()
    .background(Color.appBackground)
}
