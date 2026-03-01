import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var currentPage = 0

    private let pages: [(title: String, subtitle: String, heroImage: String)] = [
        ("Track Your Fuel", "Snap a photo of any meal and get instant calorie & macro breakdowns powered by AI.", "hero_scan_food"),
        ("Crush Your Lifts", "Log every set, rep, and PR. Build routines, track progress, and never miss a gain.", "hero_workout"),
        ("Stronger Together", "Join groups, share workouts, and compete on leaderboards with friends.", "hero_social")
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    VStack(spacing: Theme.spacingXXL) {
                        Spacer()

                        Image(pages[index].heroImage)
                            .resizable()
                            .renderingMode(.original)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 160, height: 160)

                        VStack(spacing: Theme.spacingMD) {
                            Text(pages[index].title)
                                .font(.system(size: Theme.titleSize, weight: .bold))
                                .foregroundStyle(Color.appTextPrimary)

                            Text(pages[index].subtitle)
                                .font(.system(size: Theme.bodySize))
                                .foregroundStyle(Color.appTextSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }

                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            VStack(spacing: Theme.spacingLG) {
                if currentPage < pages.count - 1 {
                    Button {
                        withAnimation {
                            currentPage += 1
                        }
                    } label: {
                        Text("Next")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(Theme.spacingMD)
                            .background(Color.appAccent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
                    }

                    Button("Skip") {
                        currentPage = pages.count - 1
                    }
                    .foregroundStyle(Color.appTextSecondary)
                } else {
                    NavigationLink {
                        GoalSetupView()
                    } label: {
                        Text("Get Started")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(Theme.spacingMD)
                            .background(Color.appAccent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLG))
                    }
                }
            }
            .padding(.horizontal, Theme.spacingXXL)
            .padding(.bottom, 40)
        }
        .screenBackground()
        .navigationBarBackButtonHidden()
    }
}
