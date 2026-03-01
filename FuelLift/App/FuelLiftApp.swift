import SwiftUI
import SwiftData

@main
struct FuelLiftApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthViewModel()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            FoodEntry.self,
            WaterEntry.self,
            Workout.self,
            Exercise.self,
            ExerciseSet.self,
            WorkoutRoutine.self,
            BodyMetric.self,
            Badge.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
        }
        .modelContainer(sharedModelContainer)
    }
}

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var badgeViewModel = BadgeViewModel()

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        Group {
            if authViewModel.isLoading {
                ProgressView("Loading...")
            } else if authViewModel.isAuthenticated {
                if authViewModel.needsOnboarding {
                    OnboardingView()
                } else {
                    ContentView()
                        .environment(badgeViewModel)
                }
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
        .task {
            if profiles.isEmpty {
                let profile = UserProfile(id: UUID().uuidString, displayName: "User", email: "")
                profile.hasCompletedOnboarding = true
                modelContext.insert(profile)
                try? modelContext.save()
            }

            // Initialize badges and check streak-based badges on launch
            badgeViewModel.initializeBadgesIfNeeded(context: modelContext)

            let dashVM = DashboardViewModel()
            let streak = dashVM.calculateStreak(context: modelContext)
            badgeViewModel.checkStreakBadges(currentStreak: streak, context: modelContext)
        }
        .preferredColorScheme({
            switch profile?.appearanceMode ?? "auto" {
            case "dark": return .dark
            case "light": return .light
            default: return nil  // auto — follows system
            }
        }())
    }
}
