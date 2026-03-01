import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @State private var showAddMeal = false

    enum Tab: String, CaseIterable {
        case home = "Home"
        case progress = "Progress"
        case workout = "Workout"
        case profile = "Profile"

        var iconName: String {
            switch self {
            case .home: return "icon_house"
            case .progress: return "icon_chart_bar"
            case .workout: return "icon_dumbbell"
            case .profile: return "icon_person"
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tabItem {
                        Label {
                            Text(Tab.home.rawValue)
                        } icon: {
                            Image(Tab.home.iconName)
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: 25, height: 25)
                        }
                    }
                    .tag(Tab.home)

                ProgressDashboardView()
                    .tabItem {
                        Label {
                            Text(Tab.progress.rawValue)
                        } icon: {
                            Image(Tab.progress.iconName)
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: 25, height: 25)
                        }
                    }
                    .tag(Tab.progress)

                WorkoutListView()
                    .tabItem {
                        Label {
                            Text(Tab.workout.rawValue)
                        } icon: {
                            Image(Tab.workout.iconName)
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: 25, height: 25)
                        }
                    }
                    .tag(Tab.workout)

                SettingsView()
                    .tabItem {
                        Label {
                            Text(Tab.profile.rawValue)
                        } icon: {
                            Image(Tab.profile.iconName)
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: 25, height: 25)
                        }
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
