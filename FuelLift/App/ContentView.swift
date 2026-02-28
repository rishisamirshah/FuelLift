import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @State private var showAddMeal = false

    enum Tab: String, CaseIterable {
        case home = "Home"
        case progress = "Progress"
        case workout = "Workout"
        case profile = "Profile"

        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .progress: return "chart.bar.fill"
            case .workout: return "dumbbell.fill"
            case .profile: return "person.fill"
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tabItem {
                        Label(Tab.home.rawValue, systemImage: Tab.home.icon)
                    }
                    .tag(Tab.home)

                ProgressDashboardView()
                    .tabItem {
                        Label(Tab.progress.rawValue, systemImage: Tab.progress.icon)
                    }
                    .tag(Tab.progress)

                WorkoutListView()
                    .tabItem {
                        Label(Tab.workout.rawValue, systemImage: Tab.workout.icon)
                    }
                    .tag(Tab.workout)

                SettingsView()
                    .tabItem {
                        Label(Tab.profile.rawValue, systemImage: Tab.profile.icon)
                    }
                    .tag(Tab.profile)
            }
            .tint(.orange)

            FloatingActionButton {
                showAddMeal = true
            }
            .padding(.trailing, Theme.spacingXL)
            .padding(.bottom, 60)
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
