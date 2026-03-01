import SwiftUI

struct FoodEntryDetailView: View {
    let entry: FoodEntry
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    // Food photo
                    if let imageData = entry.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 380)
                            .clipped()
                    }

                    // Content section with rounded top corners
                    contentSection
                        .offset(y: entry.imageData != nil ? -24 : 0)
                }
                .padding(.bottom, 80)
            }
            .ignoresSafeArea(edges: .top)

            // Fixed bottom bar
            bottomBar
        }
        .screenBackground()
        .navigationTitle("Nutrition")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: Theme.spacingMD) {
                    Button { } label: {
                        Image("icon_share").resizable().renderingMode(.original)
                            .frame(width: 20, height: 20)
                            .frame(width: 36, height: 36)
                            .background(Color.appCardSecondary.opacity(0.8))
                            .clipShape(Circle())
                    }
                    Button { } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.appTextPrimary)
                            .frame(width: 36, height: 36)
                            .background(Color.appCardSecondary.opacity(0.8))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }

    // MARK: - Content Section

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingXL) {
            // Header: bookmark + time + name + serving
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: Theme.spacingSM) {
                    HStack(spacing: Theme.spacingMD) {
                        Image(systemName: "bookmark")
                            .font(.title2)
                            .foregroundStyle(Color.appTextPrimary)

                        Text(entry.date.formatted(date: .omitted, time: .shortened))
                            .font(.system(size: Theme.captionSize, weight: .medium))
                            .foregroundStyle(Color.appTextSecondary)
                            .padding(.horizontal, Theme.spacingMD)
                            .padding(.vertical, Theme.spacingXS)
                            .background(Color.appCardSecondary)
                            .clipShape(Capsule())
                    }

                    Text(entry.name)
                        .font(.system(size: Theme.headlineSize, weight: .bold))
                        .foregroundStyle(Color.appTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                // Serving count
                HStack(spacing: Theme.spacingSM) {
                    Text("1")
                        .font(.system(size: Theme.bodySize, weight: .medium))
                    Image(systemName: "pencil")
                        .font(.system(size: Theme.captionSize))
                }
                .foregroundStyle(Color.appTextPrimary)
                .padding(.horizontal, Theme.spacingLG)
                .padding(.vertical, Theme.spacingSM)
                .background(Color.appCardSecondary)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSM))
            }

            // Calorie card
            HStack(spacing: Theme.spacingMD) {
                Image("icon_fire_streak").resizable().renderingMode(.original)
                    .frame(width: 28, height: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Calories")
                        .font(.system(size: Theme.captionSize))
                        .foregroundStyle(Color.appTextSecondary)
                    Text("\(entry.calories)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)
                }
                Spacer()
            }
            .padding(Theme.spacingLG)
            .background(Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))

            // Macro cards
            HStack(spacing: Theme.spacingSM) {
                macroCard(label: "Protein", value: Int(entry.proteinG), icon: "icon_fork_knife", color: Color.appProteinColor)
                macroCard(label: "Carbs", value: Int(entry.carbsG), icon: "icon_leaf", color: Color.appCarbsColor)
                macroCard(label: "Fats", value: Int(entry.fatG), icon: "icon_water_drop", color: Color.appFatColor)
            }

            // Page dots
            HStack(spacing: Theme.spacingXS) {
                Circle().fill(Color.appTextPrimary).frame(width: 6, height: 6)
                Circle().fill(Color.appTextTertiary).frame(width: 6, height: 6)
            }
            .frame(maxWidth: .infinity)

            // Ingredients section
            ingredientsSection

            // AI feedback row
            HStack(spacing: Theme.spacingMD) {
                Image(systemName: "face.smiling")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.appTextSecondary)
                Text("How did FuelLift AI do?")
                    .font(.system(size: Theme.bodySize, weight: .medium))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Button { } label: {
                    Image(systemName: "hand.thumbsdown")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.appTextSecondary)
                }
                Button { } label: {
                    Image(systemName: "hand.thumbsup")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .padding(Theme.spacingLG)
            .background(Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
        }
        .padding(Theme.spacingXL)
        .background(Color.appBackground)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24))
    }

    // MARK: - Macro Card

    private func macroCard(label: String, value: Int, icon: String, color: Color) -> some View {
        VStack(spacing: Theme.spacingSM) {
            HStack(spacing: Theme.spacingXS) {
                Image(icon).resizable().renderingMode(.original)
                    .frame(width: 14, height: 14)
                Text(label)
                    .font(.system(size: Theme.captionSize))
                    .foregroundStyle(Color.appTextSecondary)
            }
            Text("\(value)g")
                .font(.system(size: Theme.headlineSize, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appTextPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingLG)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
    }

    // MARK: - Ingredients

    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            HStack {
                Text("Ingredients")
                    .font(.system(size: Theme.subheadlineSize, weight: .bold))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Button { } label: {
                    HStack(spacing: Theme.spacingXS) {
                        Image(systemName: "plus")
                        Text("Add More")
                    }
                    .font(.system(size: Theme.captionSize, weight: .semibold))
                    .foregroundStyle(Color.appTextSecondary)
                }
            }

            let items = entry.ingredients
            if items.isEmpty {
                Text("No ingredient breakdown available")
                    .font(.system(size: Theme.bodySize))
                    .foregroundStyle(Color.appTextTertiary)
                    .padding(.vertical, Theme.spacingSM)
            } else {
                ForEach(Array(items.enumerated()), id: \.offset) { _, ingredient in
                    HStack {
                        Text(ingredient.name)
                            .font(.system(size: Theme.bodySize, weight: .medium))
                            .foregroundStyle(Color.appTextPrimary)
                        Text("\u{2022}")
                            .foregroundStyle(Color.appTextTertiary)
                        Text("\(ingredient.calories) cal")
                            .font(.system(size: Theme.bodySize))
                            .foregroundStyle(Color.appTextSecondary)
                        Spacer()
                    }
                    .padding(Theme.spacingLG)
                    .background(Color.appCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                }
            }
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack(spacing: Theme.spacingMD) {
            Button { } label: {
                HStack(spacing: Theme.spacingSM) {
                    Image("icon_wand_stars").resizable().renderingMode(.original).frame(width: 20, height: 20)
                    Text("Fix Issue")
                }
                .font(.system(size: Theme.subheadlineSize, weight: .semibold))
                .foregroundStyle(Color.appTextPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.spacingLG)
                .background(Color.appCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusFull))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadiusFull)
                        .stroke(Color.appCardSecondary, lineWidth: 1)
                )
            }

            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.system(size: Theme.subheadlineSize, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.spacingLG)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusFull))
            }
        }
        .padding(.horizontal, Theme.spacingLG)
        .padding(.vertical, Theme.spacingMD)
        .background(
            Color.appBackground
                .shadow(color: .black.opacity(0.15), radius: 8, y: -4)
        )
    }
}
