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
        VStack(spacing: 0) {
            // Content area
            Group {
                switch selectedTab {
                case .home: DashboardView()
                case .progress: ProgressDashboardView()
                case .workout: WorkoutListView()
                case .profile: SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()

            // Custom tab bar
            HStack {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        VStack(spacing: 4) {
                            Image(tab.iconName)
                                .resizable()
                                .interpolation(.none)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundStyle(selectedTab == tab ? Color.appAccent : Color.appTextTertiary)

                            Text(tab.rawValue)
                                .font(.system(size: 10, weight: selectedTab == tab ? .semibold : .regular))
                                .foregroundStyle(selectedTab == tab ? Color.appAccent : Color.appTextTertiary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 28)
            .background(Color.appCardBackground)
        }
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
