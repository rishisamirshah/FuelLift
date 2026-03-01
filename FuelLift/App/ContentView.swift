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
        ZStack(alignment: .bottom) {
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
            .padding(.bottom, 56)

            // Custom tab bar
            HStack {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedTab = tab
                        }
                    } label: {
                        VStack(spacing: 3) {
                            Image(tab.iconName)
                                .resizable()
                                .renderingMode(.template)
                                .interpolation(.none)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 22, height: 22)

                            Text(tab.rawValue)
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundStyle(selectedTab == tab ? Color.appAccent : Color.appTextTertiary)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 28)
            .background(
                Color.appCardBackground
                    .shadow(color: .black.opacity(0.3), radius: 8, y: -2)
                    .ignoresSafeArea(edges: .bottom)
            )

            // FAB
            FloatingActionButton {
                showAddMeal = true
            }
            .padding(.trailing, Theme.spacingXL)
            .padding(.bottom, 68)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .ignoresSafeArea(edges: .bottom)
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
