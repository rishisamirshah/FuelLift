# FuelLift Brain - Complete Project Context

> Last updated: 2026-02-28 (v2 update)
> Auto-maintained by "Update all" task

---

## Project Overview

**FuelLift** is an iOS fitness + nutrition tracking app combining calorie/macro logging (like Cal-AI) with strength training (like Strong). Built with SwiftUI, SwiftData, Firebase, HealthKit, and OpenAI. Premium Cal AI + Strong aesthetic with system-adaptive light/dark mode.

- **Bundle ID:** com.fuellift.app
- **Min iOS:** 17.0 | **Swift:** 5.9 | **Xcode:** 15.4+
- **Build System:** XcodeGen (`project.yml` → `.xcodeproj`)
- **Local Storage:** SwiftData | **Remote:** Firebase (currently disabled for local dev)
- **CI/CD:** Fastlane → TestFlight | GitHub Actions

---

## Architecture

```
FuelLift/
├── App/                    # Entry points (3 files)
│   ├── FuelLiftApp.swift   # @main, ModelContainer (9 models), RootView
│   ├── AppDelegate.swift   # Notifications (Firebase disabled)
│   └── ContentView.swift   # 4-tab bar + FAB overlay
├── Models/                 # SwiftData @Model + structs (11 files)
├── ViewModels/             # State managers (9 files)
├── Views/                  # SwiftUI views (46 files)
│   ├── Dashboard/          # 3 files
│   ├── Nutrition/          # 7 files
│   ├── Workout/            # 9 files
│   ├── Progress/           # 12 files
│   ├── Social/             # 5 files
│   ├── Settings/           # 4 files
│   └── Onboarding/         # 3 files
├── Services/               # Singletons (8 files)
├── Utilities/              # Theme, Extensions, Constants, ImagePicker
│   └── Components/         # 9 shared UI components
└── Resources/              # Info.plist, Entitlements, Assets
```

---

## Design System (Theme.swift)

### Spacing: XS(4) / SM(8) / MD(12) / LG(16) / XL(20) / XXL(24) / Huge(32)
### Corner Radius: SM(8) / MD(12) / LG(16—cards) / XL(20) / Full(100—pills)
### Typography: title(34) / headline(22) / subheadline(17) / body(15) / caption(13) / mini(11)
### Rings: calorieRing(120pt, 12pt stroke) / macroRing(56pt, 6pt stroke)

### Semantic Colors (all system-adaptive)
- **Backgrounds:** appBackground, appCardBackground, appCardSecondary, appGroupedBackground
- **Text:** appTextPrimary (label), appTextSecondary, appTextTertiary
- **Macros:** appProteinColor (#4A90D9 blue), appCarbsColor (#F5A623 orange), appFatColor (#D0021B red), appCaloriesColor (#7ED321 green)
- **Other:** appWaterColor (#50E3C2 teal), appStreakColor (#FF9500), appAccent (orange), appWorkoutGreen
- **PR Badges:** appPR1RM (teal), appPRVolume (green), appPRWeight (yellow)
- **Badge States:** appBadgeEarned (orange), appBadgeLocked (tertiaryLabel)

### View Modifiers (Extensions.swift)
- `.cardStyle()` — padding(LG) + appCardBackground + cornerRadiusLG
- `.secondaryCardStyle()` — padding(LG) + appCardSecondary + cornerRadiusMD
- `.sectionHeaderStyle()` — font 20pt bold + appTextPrimary + leading
- `.screenBackground()` — appBackground

### Gradients
- calorieRing, proteinRing, carbsRing, fatRing (color → 70% opacity)
- streakGradient (orange → red, vertical)

---

## Tab Navigation

4 tabs + Floating Action Button:

| Tab | Icon | Destination | Purpose |
|-----|------|-------------|---------|
| Home | house.fill | DashboardView | Daily summary, calorie ring, macros, streak |
| Progress | chart.bar.fill | ProgressDashboardView | Weight/calorie charts, milestones, badges |
| Workout | dumbbell.fill | WorkoutListView | Templates, active workout, history |
| Profile | person.fill | SettingsView | Profile, settings, social access |

- **FAB:** Orange FloatingActionButton bottom-right, opens FoodLogView sheet
- Social tab removed — accessible from Profile
- Tint: `.tint(.orange)`

---

## Models (SwiftData @Model)

### UserProfile
- Goals: calorieGoal (2000), proteinGoal (150g), carbsGoal (250g), fatGoal (65g), waterGoalML (2500)
- Body: heightCM, weightKG, weightGoalKG (optional), age, gender, activityLevel
- Prefs: useMetricUnits, darkModeEnabled, notificationsEnabled, healthKitEnabled
- Streaks: currentStreak, longestStreak, lastLogDate
- Onboarding: hasCompletedOnboarding; Profile: displayName, email, firestoreId
- **Auto-created:** RootView creates default UserProfile on launch if none exists (auth bypass fix)

### FoodEntry
- name, calories (Int), proteinG, carbsG, fatG, servingSize, mealType, date, imageData, barcode, source, firestoreId
- Computed: nutrition → NutritionData; Methods: toFirestoreData()

### WaterEntry — amountML (Int), date
### Exercise — name, muscleGroup, equipment, instructions, isCustom
### ExerciseSet — exerciseName, setNumber, weight, reps, rpe, isWarmup, isCompleted, isPersonalRecord; Computed: estimated1RM (Epley), volume
### WorkoutRoutine — name, exerciseNames ([String]), defaultSetsPerExercise, notes
### BodyMetric — date, weightKG?, bodyFatPercent?, chestCM?, waistCM?, hipsCM?, bicepsCM?, thighsCM?, photoData?

### Workout
- name, date, durationSeconds, notes, isCompleted, exerciseGroupsData (Data? JSON)
- Computed: totalVolume, totalSets, exerciseNames, durationFormatted
- Methods: toFirestoreData(), decodeExerciseGroups(), encodeExerciseGroups()

### Badge (NEW)
- key (String→BadgeKey), name, badgeDescription, iconName, category (String→BadgeCategory), requirement, earnedDate (Date?)
- Computed: isEarned (earnedDate != nil)

### Supporting Types
- **NutritionData** (Codable) — name, calories, proteinG, carbsG, fatG, servingSize
- **ExerciseDefinition** (Codable) — 29 predefined exercises, static loadAll()
- **WorkoutExerciseGroup** (Codable, Identifiable) — exerciseName, sets: [WorkoutSetData], isSuperset
- **WorkoutSetData** (Codable, Identifiable) — setNumber, weight, reps, rpe?, isWarmup, isCompleted, isPersonalRecord; estimated1RM, volume
- **MealType** (enum) — breakfast, lunch, dinner, snack
- **BadgeCategory** (enum) — streak, meals, workouts, strength, bodyProgress, social (displayName, gradientColors, gradient)
- **BadgeKey** (enum) — 31 cases across 6 categories
- **BadgeDefinition** (struct) — static all: 31 badge definitions with keys, names, icons, requirements
- **PRType** (enum) — oneRM, volume, weight (label, color)

---

## ViewModels

| ViewModel | Type | Key Properties | Key Methods |
|-----------|------|----------------|-------------|
| AuthViewModel | ObservableObject | isAuthenticated, isLoading, needsOnboarding | signIn(), signUp(), signInWithApple() — bypassed |
| WorkoutPlannerViewModel | ObservableObject | selectedGoal, selectedExperience, daysPerWeek, generatedPlan, refinementInput, isRefining, conversationHistory | generatePlan(), savePlan(), refinePlan() |
| BadgeViewModel (NEW) | @Observable | badges, newlyEarnedBadge, showConfetti | initializeBadgesIfNeeded(), checkStreak/Meal/Workout/PR/BodyBadges() |
| DashboardViewModel | ObservableObject | caloriesEaten, calorieGoal, macros, waterML, todayWorkout, currentStreak | loadTodayData() |
| NutritionViewModel | ObservableObject | selectedDate, todayEntries, todayWater, totals | entriesForMeal(), addFoodEntry(), deleteFoodEntry(), addWater() |
| FoodScanViewModel | ObservableObject | capturedImage, scannedNutrition, isAnalyzing, foodDescription | analyzePhoto(), analyzeDescription(), lookupBarcode(), createFoodEntry() |
| WorkoutViewModel | ObservableObject | activeWorkout, exerciseGroups, elapsedSeconds, newPRs | startWorkout(), finishWorkout(), addExercise(), completeSet(), checkForPR() |
| ProgressViewModel | ObservableObject | weightHistory, calorieHistory, exercisePRs | loadData(), loadWeightHistory(), loadCalorieHistory(), loadPRs() |
| ExerciseLibraryViewModel | ObservableObject | exercises, searchText, selectedMuscleGroup | filteredExercises (computed) |
| SocialViewModel | ObservableObject | groups, friends | loadGroups(), createGroup(), joinGroup() — Firebase dependent |

---

## Services (Singletons)

| Service | Backend | Status | Purpose |
|---------|---------|--------|---------|
| AuthService | Firebase Auth | Disabled | Email/password + Apple Sign-In |
| FirestoreService | Firestore | Disabled | Cloud data sync |
| StorageService | Firebase Storage | Disabled | Photo uploads |
| HealthKitService | HealthKit | Active | Read steps/calories, write macros/weight/workouts |
| OpenAIService | OpenAI GPT-4o | Active* | Food photo → NutritionData (needs API key) |
| ClaudeService | Anthropic Claude | Active | Workout plans, food description analysis, plan refinement, calorie calculation |
| ExerciseAPIService | wger.de | Active | Exercise images (ID map + search fallback, cached) |
| BarcodeService | Open Food Facts | Active | Barcode → NutritionData |
| NotificationService | UNNotifications | Active | Meal/workout reminders |
| SyncService | Firestore | Disabled | Pull remote → update local |

All Firebase services guard with `FirebaseApp.app() != nil`.

---

## Views (51 files)

### Dashboard (3)
- **DashboardView** — StreakBadge, WeekDaySelector, CalorieRing, MacroRings, quick actions, water, workout summary, recently uploaded, FAB
- **CalorieSummaryCard** — CalorieRing (120pt) + 3 MacroRings (56pt)
- **WorkoutSummaryCard** — Dark card: name, duration, sets, volume

### Nutrition (8)
- **FoodLogView** — Date picker, summary, water tracker, meal sections, FAB, menu: camera/barcode/describe/manual
- **FoodDescriptionView** (NEW) — Text input → Claude AI → FoodDetailView → save with source "ai_description"
- **CameraScanView** — Camera → OpenAI → FoodDetailView
- **BarcodeScanView** — AVFoundation barcode scanner
- **FoodDetailView** — Nutrition editor, **ManualFoodEntryView** — Manual form
- **MealHistoryView** — Past foods for re-log, **RecipeBuilderView** — Multi-ingredient recipes

### Workout (9)
- **WorkoutListView** — Green CTA, template grid, history, calendar toggle
- **ActiveWorkoutView** — Timer, set logging, PR badges, haptics
- **ExercisePickerView** — Search, filter dropdowns, A-Z index
- **ExerciseDetailView** — 4-tab: About(image+placeholder)/History/Charts/Records
- **RoutineEditorView** — Template editor
- **RestTimerView** — ProgressRing countdown, **SupersetGroupView** — Paired exercises
- **WorkoutCalendarView** (NEW) — Monthly grid with green checkmarks
- **WorkoutHistoryCard** (NEW) — Workout card + PRBadge component

### Progress (12)
- **ProgressDashboardView** — Scrolling: streak, weight, charts, badges, energy, BMI
- **WeightChartView** — Line chart + FilterPills (90D/6M/1Y/ALL)
- **NutritionChartView** — Stacked bar chart (protein/carbs/fat)
- **StrengthChartView** — Ranked PR list
- **BodyMeasurementsView** — Measurement cards, **ProgressPhotosView** — Photo grid
- **MilestonesView** (NEW) — Badge grid by category from BadgeDefinition.all
- **BadgeDetailView** (NEW) — Badge detail + ShareLink
- **WeightChangesCard** (NEW) — TrendRows for 3/7/14/30/90d
- **WeeklyEnergyCard** (NEW) — Burned vs Consumed bar chart
- **BMICard** (NEW) — BMI gauge (green/yellow/red), **WeightEditorView** (NEW) — Weight picker + weight goal setting + plan prompt

### Social (5) — GroupsListView, GroupDetailView, LeaderboardView (gold/silver/bronze), FriendProfileView, WorkoutShareView
### Settings (4) — SettingsView (profile header, grouped sections), ProfileEditView, NotificationSettingsView, UnitsSettingsView
### Onboarding (3) — LoginView (dark, Apple Sign-In), OnboardingView (carousel), GoalSetupView (3-step wizard + AI Calculate button)

### Shared Components (9)
- **ProgressRing** — Circular ring + CalorieRing/MacroRing variants
- **WeekDaySelector** — 7-day horizontal row
- **StreakBadge** — .compact (pill) / .expanded (card) with pulse
- **TrendRow** — Label + mini bar + trend arrow
- **FilterPills** — Selectable pills (TimeFilter, WeekFilter enums)
- **FloatingActionButton** — Orange FAB with spring + haptics
- **BadgeGridItem** — Badge cell (earned=gradient circle + white icon / locked=gray circle + star). Takes optional `category` for gradient.
- **BadgeUnlockedOverlay** — Confetti celebration overlay
- **AchievementToast** — Slide-in toast + .achievementToast() modifier

---

## Badges & Achievements (31 badges)

- **Streak (6):** Rookie(3d), Getting Serious(10d), Locked In(50d), Triple Threat(100d), No Days Off(365d), Immortal(1000d)
- **Meals (6):** First Bite(1), Forking Around(5), Nutrition Novice(20), Mission Nutrition(50), The Logfather(500), Calorie Counter(1000)
- **Workouts (5):** First Rep(1), Gym Rat(10), Iron Addict(50), Beast Mode(100), Legendary(500)
- **Strength (5):** PR Breaker(1PR), PR Machine(10PR), PR Monster(50PR), Volume King(100K lbs), Million Pound Club(1M lbs)
- **Body/Progress (6):** Weigh In, Snapshot, Transformation, Goal Crusher, Perfect Week, Hydration Hero
- **Social (3):** Social Butterfly, Team Player, Influencer

BadgeViewModel checks conditions → awardBadge() → confetti + toast.

---

## Build & Deploy

### SPM Dependencies
| Package | Version | Products |
|---------|---------|----------|
| Firebase iOS SDK | >= 11.0.0 | FirebaseAuth, FirebaseFirestore, FirebaseStorage, FirebaseMessaging |
| Lottie | >= 4.4.0 | Lottie |
| SwiftUI-Shimmer | >= 1.4.0 | Shimmer |
| ConfettiSwiftUI | >= 1.1.0 | ConfettiSwiftUI |

### Build: `xcodegen generate` then `xcodebuild -scheme FuelLift ...`

---

## Current Dev Status

- **Firebase:** Disabled. All services guard with `FirebaseApp.app() != nil`.
- **Auth:** Bypassed — isAuthenticated = true on init.
- **Local data:** SwiftData fully functional.
- **OpenAI:** Requires OPENAI_API_KEY.
- **Claude AI:** Anthropic API integrated for: workout planner, food description analysis, plan refinement (multi-turn), AI calorie calculator (key in Constants.swift).
- **HealthKit:** Active (requires device support).
- **UI:** Premium Cal AI + Strong aesthetic. System-adaptive light/dark with in-app dark mode toggle. All Theme design tokens.
- **Build:** Compiles cleanly (0 errors).

### Known Warnings
- HKWorkout init deprecated iOS 17 (HealthKitService)
- Unused StorageReference (StorageService)
- Unused credential variable (AuthService)

### Recently Implemented (v2)
- **UserProfile auto-creation** — RootView creates default profile on launch when auth bypassed (fixes all toggle bugs)
- **Exercise image ID map** — ExerciseAPIService has static wger ID map for 29 exercises, direct lookup + search fallback
- **Badge gradient visuals** — BadgeCategory has per-category gradient colors; BadgeGridItem shows gradient circles for earned badges
- **Text food description** — FoodDescriptionView → Claude AI → NutritionData → FoodDetailView
- **Weight goal setting** — WeightEditorView has goal section; ProgressDashboardView reads profile.weightGoalKG
- **AI plan refinement** — WorkoutPlannerView has refinement TextField; multi-turn conversation history
- **AI calorie calculator** — GoalSetupView has "AI Calculate" button on step 3 with reasoning disclosure

### Deferred Features (Next Implementation Cycle)
- **Workout Sharing** — Export routines as shareable links/text, import shared workouts from others
- **Firebase Integration** — Re-enable Auth, Firestore sync, Storage for cloud data
- **Custom Exercise Creation** — `isCustom` flag exists on Exercise model but no UI to create/edit custom exercises
- **Superset/Dropset Support** — SupersetGroupView exists but isn't integrated into ActiveWorkoutView
- **Rest Timer Customization** — Currently hardcoded 90s, needs user-configurable duration
- **Workout Rating/RPE Summary** — Post-workout RPE rating at finish

---

## File Count Summary

| Directory | Files |
|-----------|-------|
| App | 3 |
| Models | 11 |
| ViewModels | 10 |
| Views | 49 |
| Components | 9 |
| Services | 10 |
| Utilities | 4 |
| Resources | 3 |
| **Total Swift** | **93** |
