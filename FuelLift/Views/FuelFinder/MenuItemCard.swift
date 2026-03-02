import SwiftUI

struct MenuItemCard: View {
    let item: MenuItem
    let score: MenuItemScore
    let profile: UserProfile?
    @State private var showDetail = false

    var body: some View {
        Button {
            showDetail = true
        } label: {
            HStack(spacing: Theme.spacingMD) {
                // Food image
                if let imageURL = item.imageURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default:
                            foodPlaceholder
                        }
                    }
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSM))
                } else {
                    foodPlaceholder
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSM))
                }

                // Info
                VStack(alignment: .leading, spacing: Theme.spacingXS) {
                    Text(item.name)
                        .font(.system(size: Theme.bodySize, weight: .semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text("\(item.calories) cal")
                        .font(.system(size: Theme.captionSize, weight: .medium))
                        .foregroundStyle(Color.appCaloriesColor)

                    HStack(spacing: Theme.spacingSM) {
                        macroLabel("P", value: item.proteinG, color: Color.appProteinColor)
                        macroLabel("C", value: item.carbsG, color: Color.appCarbsColor)
                        macroLabel("F", value: item.fatG, color: Color.appFatColor)
                    }
                }

                Spacer()

                // Score badge
                scoreBadge
            }
            .cardStyle()
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetail) {
            MenuItemDetailView(item: item, score: score, profile: profile)
        }
    }

    // MARK: - Components

    private func macroLabel(_ letter: String, value: Double, color: Color) -> some View {
        HStack(spacing: 2) {
            Text(letter)
                .font(.system(size: Theme.miniSize, weight: .bold))
                .foregroundStyle(color)
            Text("\(Int(value))")
                .font(.system(size: Theme.miniSize))
                .foregroundStyle(Color.appTextSecondary)
        }
    }

    private var scoreBadge: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .stroke(score.label.color, lineWidth: 3)
                    .frame(width: 44, height: 44)

                Text("\(score.score)")
                    .font(.system(size: Theme.bodySize, weight: .bold))
                    .foregroundStyle(score.label.color)
            }

            Text(score.label.rawValue)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(score.label.color)
        }
    }

    private var foodPlaceholder: some View {
        ZStack {
            FoodCategoryMapper.backgroundColor(for: item.name)
            Text(FoodCategoryMapper.emoji(for: item.name))
                .font(.system(size: 36))
        }
    }
}
