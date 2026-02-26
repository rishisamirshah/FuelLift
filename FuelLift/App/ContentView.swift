import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .dashboard

    enum Tab: String, CaseIterable {
        case dashboard = "Dashboard"
        case nutrition = "Nutrition"
        case workout = "Workout"
        case progress = "Progress"
        case social = "Social"

        var icon: String {
            switch self {
            case .dashboard: return "house.fill"
            case .nutrition: return "fork.knife"
            case .workout: return "dumbbell.fill"
            case .progress: return "chart.line.uptrend.xyaxis"
            case .social: return "person.3.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label(Tab.dashboard.rawValue, systemImage: Tab.dashboard.icon)
                }
                .tag(Tab.dashboard)

            FoodLogView()
                .tabItem {
                    Label(Tab.nutrition.rawValue, systemImage: Tab.nutrition.icon)
                }
                .tag(Tab.nutrition)

            WorkoutListView()
                .tabItem {
                    Label(Tab.workout.rawValue, systemImage: Tab.workout.icon)
                }
                .tag(Tab.workout)

            ProgressDashboardView()
                .tabItem {
                    Label(Tab.progress.rawValue, systemImage: Tab.progress.icon)
                }
                .tag(Tab.progress)

            GroupsListView()
                .tabItem {
                    Label(Tab.social.rawValue, systemImage: Tab.social.icon)
                }
                .tag(Tab.social)
        }
        .tint(.orange)
    }
}
