# FuelLift Brain - Complete Project Context

> Last updated: 2026-02-28 (v5 — Pixel Art Visual Overhaul)
> Auto-maintained by "Update all" task

---

## Project Overview

**FuelLift** is an iOS fitness + nutrition tracking app combining calorie/macro logging (like Cal-AI) with strength training (like Strong). Built with SwiftUI, SwiftData, Firebase, HealthKit, and OpenAI. Premium Cal AI + Strong aesthetic with system-adaptive light/dark mode.

- **Bundle ID:** com.fuellift.app
- **Min iOS:** 17.0 | **Swift:** 5.9 | **Xcode:** 16.2
- **Build System:** XcodeGen (`project.yml` → `.xcodeproj`)
- **Local Storage:** SwiftData | **Remote:** Firebase (currently disabled for local dev)
- **CI/CD:** GitHub Actions → Fastlane → TestFlight (fully automated, push to `main` deploys)
- **Code Signing:** Fastlane Match (manual, app-store type) | Certs stored in private git repo
- **Branches:** `main` (triggers CI), `development` (synced)

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
├── Views/                  # SwiftUI views (47 files)
│   ├── Dashboard/          # 3 files
│   ├── Nutrition/          # 10 files
│   ├── Workout/            # 9 files
│   ├── Progress/           # 12 files
│   ├── Social/             # 5 files
│   ├── Settings/           # 4 files
│   └── Onboarding/         # 3 files
├── Services/               # Singletons (8 files)
├── Utilities/              # Theme, Extensions, Constants, ImagePicker
│   └── Components/         # 9 shared UI components
└── Resources/              # Info.plist, Entitlements, Assets.xcassets (AppIcon)
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
- Nutrition Plan: dietaryPreference (String?), workoutsPerWeek (Int?), targetWeightKG (Double?)
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
| ClaudeService | Anthropic Claude | Active | Workout plans, food photo/description analysis, plan refinement, nutrition goal calculator (enhanced: dietary pref, target weight, workouts/week) |
| ExerciseAPIService | wger.de | Active | Exercise images (ID map + search fallback, cached) |
| BarcodeService | Open Food Facts | Active | Barcode → NutritionData |
| NotificationService | UNNotifications | Active | Meal/workout reminders |
| SyncService | Firestore | Disabled | Pull remote → update local |

All Firebase services guard with `FirebaseApp.app() != nil`.

---

## Views (52 files)

### Dashboard (3)
- **DashboardView** — StreakBadge, WeekDaySelector, CalorieRing, MacroRings, quick actions (Scan Food, Start Workout, AI Nutrition Plan), water, workout summary, recently uploaded, FAB
- **CalorieSummaryCard** — CalorieRing (120pt) + 3 MacroRings (56pt)
- **WorkoutSummaryCard** — Dark card: name, duration, sets, volume

### Nutrition (10)
- **FoodLogView** — Date picker, summary, water tracker, meal sections, FAB, menu: camera/barcode/describe/manual
- **NutritionPlanView** — In-depth AI nutrition questionnaire: body stats, goal cards, target weight, activity/workouts stepper, dietary preference pills (FlowLayout), AI Generate button, all 4 editable macros, reset to defaults, sticky save. Opened from Dashboard quick action + Settings.
- **FoodDescriptionView** — Text input → Claude AI → FoodDetailView → save with source "ai_description"
- **CameraScanView** — Camera → Claude Vision → FoodDetailView
- **BarcodeScanView** — AVFoundation barcode scanner
- **FoodDetailView** — Nutrition editor, **ManualFoodEntryView** — Manual form
- **MealHistoryView** — Past foods for re-log, **RecipeBuilderView** — Multi-ingredient recipes
- **FoodEntryDetailView** — Detail view for logged food entries

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
### Settings (4) — SettingsView (profile header, grouped sections, "Edit Nutrition Goals" → NutritionPlanView), ProfileEditView, NotificationSettingsView, UnitsSettingsView
### Onboarding (3) — LoginView (dark, Apple Sign-In), OnboardingView (carousel), GoalSetupView (3-step wizard + AI Calculate, used for onboarding only)

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

### CI/CD Pipeline (GitHub Actions → TestFlight)
- **Trigger:** Push to `main` or manual workflow_dispatch
- **Runner:** macos-14, Xcode 16.2
- **Flow:** Checkout → XcodeGen → Ruby/Fastlane → GoogleService-Info.plist (placeholder) → SPM resolve → Fastlane beta lane
- **Fastlane beta lane:** setup_ci → App Store Connect API key → Match (readonly) → increment_build_number (timestamp) → build_app → upload_to_testflight
- **Signing:** Manual code signing on FuelLift target only (SPM packages use automatic). Match profile: "match AppStore com.fuellift.app"
- **Workflows:** `testflight.yml` (auto deploy), `setup-certificates.yml` (one-time cert generation)
- **Required GitHub Secrets:** ASC_KEY_ID, ASC_ISSUER_ID, ASC_PRIVATE_KEY, MATCH_PASSWORD, MATCH_GIT_URL, MATCH_GIT_AUTH, DEVELOPMENT_TEAM, ANTHROPIC_API_KEY, OPENAI_API_KEY
- **App Icon:** Pixel art lifter character, 1024x1024 PNG (single-size format, Xcode generates all sizes)
- **Encryption compliance:** ITSAppUsesNonExemptEncryption=false (auto-skips compliance prompt)

---

## Current Dev Status

- **Firebase:** Disabled. All services guard with `FirebaseApp.app() != nil`.
- **Auth:** Bypassed — isAuthenticated = true on init.
- **Local data:** SwiftData fully functional.
- **OpenAI:** Requires OPENAI_API_KEY.
- **Claude AI:** Anthropic API integrated for: workout planner, food photo/description analysis, plan refinement (multi-turn), AI nutrition plan calculator with dietary preference + target weight + workout frequency (key in Constants.swift).
- **HealthKit:** Active (requires device support).
- **UI:** Retro pixel art aesthetic (orange on black, 8-bit sprites). 122 custom pixel art assets replace SF Symbols app-wide. System-adaptive light/dark with in-app dark mode toggle. All Theme design tokens.
- **Build:** Compiles cleanly (0 errors). CI/CD fully operational — push to `main` auto-deploys to TestFlight.
- **TestFlight:** Live, internal testing group set up with testers.

### Known Warnings
- HKWorkout init deprecated iOS 17 (HealthKitService)
- Unused StorageReference (StorageService)
- Unused credential variable (AuthService)
- "All interface orientations must be supported unless the app requires full screen" (build warning, non-blocking)

### Recently Implemented (v5 — Pixel Art Visual Overhaul)
- **122 pixel art assets generated** via Gemini Nano Banana — icons (51), badges (31), exercises (26), heroes (3), other (11)
- **32 Swift files modified** — SF Symbols replaced with `Image("asset_name").resizable().renderingMode(.original).frame()` pattern
- **App icon** — Pixel art lifter character replaces green placeholder
- **Logo** — "FUEL [figure] LIFT" pixel art header in DashboardView
- **Tab bar** — Pixel art house, chart, dumbbell, person icons
- **All settings rows** — Every icon replaced with pixel art
- **Onboarding** — 3 hero illustrations (scan food, workout, social) replace SF Symbol circles
- **Login** — Pixel art logo replaces flame SF Symbol
- **31 badge artworks** — Unique pixel art per badge (Rookie→phoenix, First Bite→godfather, etc.)
- **26 exercise illustrations** — Every exercise has pixel art showing the movement
- **Macro ring emojis** — 🥩→pixel meat, 🍞→pixel bread, 🧈→pixel butter
- **Streak badge** — 🔥 emoji → pixel art flame (compact + expanded)
- **Exercise detail** — Local pixel art shown first via ID mapping, API fallback preserved
- **Badge system** — BadgeGridItem/BadgeDetailView/BadgeUnlockedOverlay all load custom images
- **FAB** — Pixel art plus icon
- **Image generation script** — `scripts/generate_image.py` with baked-in style prefix for consistent aesthetic

### Previously Implemented (v4 — AI Nutrition Plan)
- **NutritionPlanView** — In-depth single-page questionnaire replacing GoalSetupView for editing: body stats, goal cards, target weight, activity level + workouts/week stepper, dietary preference pills (Standard/High Protein/Low Carb/Keto/Vegetarian/Vegan), AI Generate button, all 4 editable macro fields, reset to defaults, sticky save button
- **Dashboard quick action** — "AI Nutrition Plan" button added as full-width third action below Scan Food + Start Workout
- **Enhanced ClaudeService prompt** — calculateNutritionGoals() now accepts dietaryPreference, targetWeightKG, workoutsPerWeek; uses Mifflin-St Jeor + dietary-specific macro ratios
- **UserProfile new fields** — dietaryPreference (String?), workoutsPerWeek (Int?), targetWeightKG (Double?)
- **Settings redirect** — "Edit Nutrition Goals" now opens NutritionPlanView instead of GoalSetupView
- **FlowLayout** — Custom SwiftUI Layout for wrapping dietary preference pills
- **GoalSetupView preserved** — Still used for onboarding wizard (unchanged)

### Previously Implemented (v3 — CI/CD)
- **TestFlight pipeline** — Fully automated: push to main → GitHub Actions → Fastlane → TestFlight (~15 min)
- **One-time cert setup workflow** — `setup-certificates.yml` generates Match certs without needing a Mac locally
- **App icon asset catalog** — Created Assets.xcassets with placeholder AppIcon (single-size 1024x1024)
- **Info.plist metadata** — Added all required keys: CFBundleIconName, UILaunchScreen, orientations, health descriptions, encryption compliance
- **Per-target code signing** — Manual signing only on FuelLift target; SPM packages use automatic signing (fixes "conflicting provisioning settings")

### Gemini Image Generation (Active)
- **Script:** `scripts/generate_image.py` — Python, uses `google-genai` SDK
- **Model:** Nano Banana (`gemini-2.5-flash-image`) — $0.039/image
- **Style:** Chunky solid filled pixel art, orange/dark orange on black, white sparkle stars, retro 8-bit
- **Usage:** `python generate_image.py "prompt" -o output.png -m nano`
- **Models available:** `nano` (default, fast), `pro` (high quality), `nano2` (latest)
- **Reference aesthetic:** `C:\Users\12147\Pictures\8d0397a0-e9f8-4270-9894-2a2296800244.jfif`

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
| Views | 50 |
| Components | 9 |
| Services | 10 |
| Utilities | 4 |
| Resources | 5 |
| Scripts | 1 |
| Asset Images | 122 |
| **Total Swift** | **94** |
