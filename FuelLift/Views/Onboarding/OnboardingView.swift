import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var currentPage = 0

    private let pages: [(title: String, subtitle: String, icon: String)] = [
        ("Track Your Fuel", "Snap a photo of any meal and get instant calorie & macro breakdowns powered by AI.", "camera.fill"),
        ("Crush Your Lifts", "Log every set, rep, and PR. Build routines, track progress, and never miss a gain.", "dumbbell.fill"),
        ("Stronger Together", "Join groups, share workouts, and compete on leaderboards with friends.", "person.3.fill")
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    VStack(spacing: Theme.spacingXXL) {
                        Spacer()

                        ZStack {
                            Circle()
                                .fill(Color.appAccent.opacity(0.15))
                                .frame(width: 160, height: 160)

                            Image(systemName: pages[index].icon)
                                .font(.system(size: 72))
                                .foregroundStyle(Color.appAccent.gradient)
                        }

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
