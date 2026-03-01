import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @State private var showAddMeal = false

    enum Tab: String, CaseIterable {
        case home = "Home"
        case progress = "Progress"
        case fuelFinder = "FuelFinder"
        case workout = "Workout"
        case profile = "Profile"

        var iconName: String {
            switch self {
            case .home: return "icon_house"
            case .progress: return "icon_chart_bar"
            case .fuelFinder: return "mappin.and.ellipse"
            case .workout: return "icon_dumbbell"
            case .profile: return "icon_person"
            }
        }

        var useSFSymbol: Bool {
            self == .fuelFinder
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Content area with scanline CRT overlay
            Group {
                switch selectedTab {
                case .home: DashboardView()
                case .progress: ProgressDashboardView()
                case .fuelFinder: FuelFinderView()
                case .workout: WorkoutListView()
                case .profile: SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .scanlineOverlay()

            // Retro-futuristic arcade tab bar
            VStack(spacing: 0) {
                // Top accent gradient line
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appAccent.opacity(0.1),
                                Color.appAccent.opacity(0.5),
                                Color.appAccent.opacity(0.1)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 2)

                HStack(spacing: 0) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        let isSelected = selectedTab == tab

                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                selectedTab = tab
                            }
                        } label: {
                            VStack(spacing: 6) {
                                Group {
                                    if tab.useSFSymbol {
                                        Image(systemName: tab.iconName)
                                            .font(.system(size: Theme.tabBarIconSize, weight: .medium))
                                            .foregroundStyle(isSelected ? Color.appAccent : Color.appTextTertiary)
                                    } else {
                                        Image(tab.iconName)
                                            .pixelArt()
                                            .opacity(isSelected ? 1.0 : 0.35)
                                    }
                                }
                                .frame(width: Theme.tabBarIconSize, height: Theme.tabBarIconSize)
                                .scaleEffect(isSelected ? 1.1 : 1.0)

                                Text(tab.rawValue)
                                    .font(.system(
                                        size: 10,
                                        weight: isSelected ? .semibold : .regular,
                                        design: isSelected ? .rounded : .default
                                    ))
                                    .foregroundStyle(isSelected ? Color.appAccent : Color.appTextTertiary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 10)
                            .padding(.bottom, 6)
                            .overlay(alignment: .bottom) {
                                // Glowing orange underline indicator
                                if isSelected {
                                    RoundedRectangle(cornerRadius: 1.5)
                                        .fill(Color.appAccent)
                                        .frame(width: 32, height: 3)
                                        .shadow(color: Color.appAccent.opacity(0.6), radius: 6, y: 0)
                                        .shadow(color: Color.appAccent.opacity(0.3), radius: 12, y: 0)
                                        .transition(.opacity.combined(with: .scale(scale: 0.5)))
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 4)
                .padding(.bottom, 28)
            }
            .background(Color.appCardBackground)
        }
        .screenBackground()
        .overlay(alignment: .bottomTrailing) {
            FloatingActionButton {
                showAddMeal = true
            }
            .padding(.trailing, Theme.spacingXL)
            .padding(.bottom, 90)
        }
        .sheet(isPresented: $showAddMeal) {
            NavigationStack {
                FoodLogView()
                    .navigationTitle("Log Meal")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Done") { showAddMeal = false }
                                .foregroundStyle(Color.appAccent)
                        }
                    }
            }
        }
    }
}
