# FuelLift Brain - Complete Project Context

> Last updated: 2026-03-01 (v8 — Cal AI-Inspired Feature Overhaul)
> Auto-maintained by "Update all" task

---

## Project Overview

**FuelLift** is an iOS fitness + nutrition tracking app combining calorie/macro logging (like Cal-AI) with strength training (like Strong). Built with SwiftUI, SwiftData, Firebase, HealthKit, and AI services (Gemini + Claude). Retro-futuristic pixel art aesthetic — dark arcade theme with orange accents and 8-bit sprites, with adaptive light mode support.

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
│   ├── FuelLiftApp.swift   # @main, ModelContainer (9 models), RootView, BadgeViewModel init
│   ├── AppDelegate.swift   # Notifications (Firebase disabled)
│   └── ContentView.swift   # Custom 4-tab bar + FAB overlay + scanline CRT
├── Models/                 # SwiftData @Model + structs (11 files)
├── ViewModels/             # State managers (10 files)
├── Views/                  # SwiftUI views (55 files)
│   ├── Dashboard/          # 6 files (added DashboardPagerView, StepsBurnedPage, WaterPage)
│   ├── Nutrition/          # 11 files (added FixIssueSheet)
│   ├── Workout/            # 10 files
│   ├── Progress/           # 12 files
│   ├── Social/             # 5 files
│   ├── Settings/           # 5 files
│   └── Onboarding/         # 3 files
├── Services/               # Singletons (11 files)
├── Utilities/              # Theme, Extensions, Constants, ImagePicker
│   └── Components/         # 9 shared UI components
└── Resources/              # Info.plist, Entitlements, Assets.xcassets (123 images)
```

---

## Design System (Theme.swift) — Adaptive Dark/Light

### Spacing: XS(4) / SM(8) / MD(12) / LG(16) / XL(20) / XXL(24) / Huge(32)
### Corner Radius: SM(8) / MD(12) / LG(16—cards) / XL(20) / Full(100—pills)
### Typography: title(34) / headline(22) / subheadline(17) / body(15) / caption(13) / mini(11)
### Rings: calorieRing(120pt, 12pt stroke) / macroRing(56pt, 6pt stroke)
### Glow: glowRadius(8) / glowRadiusLG(16) / glowOpacity(0.35)
### Borders: borderWidth(1) / borderWidthThick(2) / pixelStep(4)

### Color Palette — Adaptive via UIColor dynamic provider
All colors adapt automatically based on color scheme (dark/light).

**Dark Mode:**
- **Backgrounds:** appBackground (#08080F deep black), appCardBackground (#12121E), appCardSecondary (#1A1A2A), appGroupedBackground (#0D0D17)
- **Text:** appTextPrimary (white), appTextSecondary (white 60%), appTextTertiary (white 30%)
- **Macros (neon-tinted):** appProteinColor (#59A5FF), appCarbsColor (#FFBF33), appFatColor (#FF4D59), appCaloriesColor (#66E640)
- **Borders:** appBorder (white 8%), appBadgeLocked (white 20%)

**Light Mode:**
- **Backgrounds:** appBackground (#F7F7F9 light gray), appCardBackground (#FFFFFF white), appCardSecondary (#F0F0F5), appGroupedBackground (#EEEEF3)
- **Text:** appTextPrimary (#1C1C2E near-black), appTextSecondary (black 55%), appTextTertiary (black 25%)
- **Macros (deeper):** appProteinColor (#3380E6), appCarbsColor (#D99E0D), appFatColor (#E03340), appCaloriesColor (#40B326)
- **Borders:** appBorder (black 8%), appBadgeLocked (black 15%)

**Same in both modes:**
- **Accent:** appAccent (#FF6B00 hot orange), appAccentBright (#FF8C26), appAccentDim (#CC5500)
- **Status:** appStreakColor (#FF9500), appPRColor (#00CCE6), appWorkoutGreen
- **Badge:** appBadgeEarned (#FF6B00), appBorderAccent (orange 30%)

### Appearance Modes
- **Auto** (default) — follows system setting
- **Light** — forces light mode
- **Dark** — forces dark mode
- Controlled via `UserProfile.appearanceMode` ("auto" | "light" | "dark")
- Applied in `RootView` via `.preferredColorScheme()`
- Settings UI: visual card picker (mini app preview thumbnails) with checkmark in PreferencesView

### View Modifiers (Extensions.swift + DashboardView.swift)
- `.cardStyle()` — padding(LG) + appCardBackground + cornerRadiusLG + orange accent border + subtle shadow
- `.secondaryCardStyle()` — padding(LG) + appCardSecondary + cornerRadiusMD + subtle border + shadow
- `.pixelCardStyle()` — pixel-stepped corners (PixelBorder shape) + orange accent
- `.pixelButtonStyle()` — full-width retro button with gradient orange border
- `.primaryButtonStyle()` — filled orange button with glow shadow
- `.sectionHeaderStyle()` — font 20pt bold + appTextPrimary + leading
- `.screenBackground()` — appBackground (adaptive)
- `.accentGlow(radius:)` — orange shadow glow effect
- `.scanlineOverlay(opacity:)` — CRT horizontal lines for retro atmosphere
- `.pixelDivider()` — thin line with subtle accent
- `.if(_:transform:)` — conditional view modifier
- `.shimmer()` — animated shimmer overlay for loading placeholders (defined in DashboardView)

### Image Helper
- `Image("name").pixelArt()` — `.resizable().renderingMode(.original).interpolation(.none).aspectRatio(contentMode: .fit)` (returns `some View`, chain `.frame()` after)

### Custom Shapes
- **PixelBorder** — stepped corner shape for retro card borders
- **ScanlinePattern** — horizontal line pattern for CRT overlay

### Gradients
- calorieRing, proteinRing, carbsRing, fatRing (color → 60% opacity)
- stepsRing (appAccent → appAccentBright), burnedRing (appFatColor), waterRing (appWaterColor)
- streakGradient (orange → red, vertical)
- accentGlow (orange 60% → 15%, vertical)

---

## Tab Navigation

4 tabs + Floating Action Button (custom VStack-based, NOT SwiftUI TabView):

| Tab | Icon Asset | Destination | Purpose |
|-----|------------|-------------|---------|
| Home | icon_house | DashboardView | Daily summary, calorie ring, macros, streak |
| Progress | icon_chart_bar | ProgressDashboardView | Weight/calorie charts, milestones, badges |
| Workout | icon_dumbbell | WorkoutListView | Templates, active workout, history |
| Profile | icon_person | SettingsView | Profile, settings, social access |

- **Tab bar design:** Dark bg, orange gradient top line, glowing 3px orange underline on selected tab, spring animation, icon scale 1.1x on select
- **FAB:** Orange FloatingActionButton bottom-right with glow + ring border, opens FoodLogView sheet
- **CRT overlay:** Scanline pattern on content area
- Social tab removed — accessible from Profile

---

## Models (SwiftData @Model)

### UserProfile
- Goals: calorieGoal (2000), proteinGoal (150g), carbsGoal (250g), fatGoal (65g), waterGoalML (2500)
- Body: heightCM, weightKG, weightGoalKG (optional), age, gender, activityLevel
- Nutrition Plan: dietaryPreference (String?), workoutsPerWeek (Int?), targetWeightKG (Double?)
- Prefs: useMetricUnits, darkModeEnabled (legacy), notificationsEnabled, healthKitEnabled
- **Appearance:** appearanceMode (String, default "auto") — "auto", "light", "dark"
- **Feature Toggles (v8):** enableBadgeCelebrations (true), enableLiveActivity (false), addBurnedCalories (false), rolloverCalories (false)
- Dashboard toggles: showStreakBadge, showQuickActions, showMacrosBreakdown, showWaterTracker, showWorkoutSummary
- Streaks: currentStreak, longestStreak, lastLogDate
- Onboarding: hasCompletedOnboarding; Profile: displayName, email, firestoreId
- Reminder times: breakfastReminderHour/Minute, lunchReminderHour/Minute, dinnerReminderHour(18)/Minute(0)
- **Auto-created:** RootView creates default UserProfile on launch if none exists

### FoodEntry
- name, calories (Int), proteinG, carbsG, fatG, servingSize, mealType, date, imageData, barcode, source, firestoreId, ingredientsJSON
- **v8 Fields:** analysisStatus (String, default "completed") — "pending", "analyzing", "completed", "failed"
- **v8 Fields:** aiFeedback (String, default "none") — "none", "thumbs_up", "thumbs_down"
- Computed: ingredients ([NutritionData.Ingredient]), nutrition (NutritionData)

### WaterEntry — amountML (Int), date
### Exercise — name, muscleGroup, equipment, instructions, isCustom (45 predefined exercises)
### ExerciseSet — exerciseName, setNumber, weight, reps, rpe, isWarmup, isCompleted, isPersonalRecord
### WorkoutRoutine — name, exerciseNames ([String]), defaultSetsPerExercise, notes
### BodyMetric — date, weightKG?, bodyFatPercent?, chestCM?, waistCM?, hipsCM?, bicepsCM?, thighsCM?, photoData?

### Workout
- name, date, durationSeconds, notes, isCompleted, exerciseGroupsData (Data? JSON)

### Badge
- key (String→BadgeKey), name, badgeDescription, iconName, category (String→BadgeCategory), requirement, earnedDate (Date?)
- Computed: isEarned (earnedDate != nil)

### Supporting Types
- **BadgeCategory** (enum) — streak, meals, workouts, strength, bodyProgress, social (displayName, gradientColors, gradient)
- **BadgeKey** (enum) — 31 cases across 6 categories
- **BadgeDefinition** (struct) — static all: 31 badge definitions with keys, names, icons, requirements, imageName
- **PRType** (enum) — oneRM, volume, weight (label, color)

---

## ViewModels

| ViewModel | Type | Key Properties | Key Methods |
|-----------|------|----------------|-------------|
| AuthViewModel | ObservableObject | isAuthenticated, isLoading, needsOnboarding | signIn(), signUp(), signInWithApple() — bypassed |
| BadgeViewModel | @Observable | badges, newlyEarnedBadge, showConfetti | initializeBadgesIfNeeded(), check*Badges(), recheckAllBadges(), awardBadge() |
| DashboardViewModel | ObservableObject | caloriesEaten, calorieGoal, macros, waterML, todayWorkout, currentStreak, stepsToday, activeCaloriesBurned, pendingEntries | loadDashboard(for:), calculateStreak() |
| NutritionViewModel | ObservableObject | selectedDate, todayEntries, todayWater, totals, badgeViewModel | addFoodEntry() (checks meal+streak badges), deleteFoodEntry() |
| WorkoutViewModel | ObservableObject | activeWorkout, exerciseGroups, elapsedSeconds, newPRs, badgeViewModel | startWorkout(), finishWorkout() (checks workout+PR badges) |
| ProgressViewModel | ObservableObject | weightHistory, calorieHistory, exercisePRs | loadData() |
| FoodScanViewModel | ObservableObject | capturedImage, scannedNutrition, onPendingEntry | analyzePhoto(), analyzeDescription(), createPendingEntry() — **uses GeminiService** |
| WorkoutPlannerViewModel | ObservableObject | selectedGoal, generatedPlan | generatePlan(), savePlan(), refinePlan() — **uses ClaudeService** |
| ExerciseLibraryViewModel | ObservableObject | exercises, searchText | filteredExercises |
| SocialViewModel | ObservableObject | groups, friends | — Firebase dependent |

---

## Dashboard (v8 Redesign)

### Layout (DashboardView.swift)
1. **Header** — logo + StreakBadge (if streak > 0)
2. **WeekDaySelector** — scrollable 21-day (3 weeks back) horizontal ScrollViewReader, auto-scrolls to selected date, month labels on week boundaries
3. **DashboardPagerView** — swipeable 3-page TabView with page dots:
   - Page 1: CalorieSummaryCard (calorie ring + macro rings)
   - Page 2: StepsBurnedPage (steps + active calories from HealthKit, dual progress rings)
   - Page 3: WaterPage (water ring + add buttons)
4. **Quick Actions** — Scan Food, Start Workout, AI Nutrition Plan
5. **WorkoutSummaryCard** — today's completed workout
6. **Recently Uploaded** — food list with shimmer loading cards for pending entries, context menu delete

### Instant Food Add Flow
1. User opens camera → takes photo
2. Pending FoodEntry created immediately (analysisStatus="pending", name="Analyzing...", zero macros)
3. Camera sheet dismisses → dashboard shows shimmer card with food thumbnail
4. Gemini analysis continues in background
5. On completion → entry updated with real data, analysisStatus="completed", shimmer resolves to real card
6. On failure → analysisStatus="failed", name="Analysis failed"

---

## AI Services

### GeminiService (Food Scanning)
- **File:** `Services/GeminiService.swift`
- **Singleton:** `GeminiService.shared`
- **Model:** `gemini-2.5-flash` (stable, text+vision)
- **API:** REST direct (no SDK), API key as query param
- **Methods:**
  - `analyzeFoodPhoto(_:)` → `NutritionData`
  - `analyzeFoodDescription(_:)` → `NutritionData`
  - `correctFoodAnalysis(original:issue:image:)` → `NutritionData` **(v8 — Fix Issue reprompt)**
- **Features:** `responseMimeType: "application/json"` + `responseSchema` for clean JSON, 30s timeout, fallback Int/Double decoding, safety filter detection

### ClaudeService (Workout Plans & Nutrition Goals)
- **File:** `Services/ClaudeService.swift`
- **Singleton:** `ClaudeService.shared`
- **Model:** `claude-sonnet-4-6`
- **API:** Anthropic REST API with `x-api-key` header
- **Methods:** `generateWorkoutPlan()`, `refineWorkoutPlan()`, `calculateNutritionGoals()`
- **API Key:** `ANTHROPIC_API_KEY` via Info.plist → `AppConstants.anthropicAPIKey`

### API Key Chain (for both services)
GitHub Secrets → testflight.yml env → Fastfile xcargs → project.yml build settings → Info.plist → Bundle.main.infoDictionary → Constants.swift

---

## Food Entry Detail (v8)

### FoodEntryDetailView
- Full-bleed photo (380pt) with rounded-top content overlay
- Calorie card, macro cards (Protein/Carbs/Fats), ingredients list
- **AI Feedback Row** — thumbs up (green highlight) / thumbs down (red highlight, opens Fix Issue sheet)
  - Saves to `entry.aiFeedback` via modelContext
- **Fix Issue Button** — presents FixIssueSheet

### FixIssueSheet (NEW v8)
- Shows current analysis (thumbnail + name + macros)
- TextEditor for user to describe the issue
- "Re-analyze with AI" button → calls `GeminiService.correctFoodAnalysis()`
- Updates entry with corrected data on success, dismisses

---

## Preferences (v8 Redesign)

### PreferencesView (full rewrite)
- **Appearance Section** — 3 visual card thumbnails (Light/Dark/Auto) with mini app preview, orange border + checkmark on selected
- **Feature Toggles Section** — card with 4 toggle rows:
  - Badge Celebrations (confetti on badge earn) → `enableBadgeCelebrations`
  - Live Activity (lock screen calories) → `enableLiveActivity`
  - Add Burned Calories (HealthKit active cals to budget) → `addBurnedCalories`
  - Rollover Calories (unused cals carry forward) → `rolloverCalories`
- **Water Goal** — stepper 500–5000 mL in 250 mL steps
- **Units** — NavigationLink to UnitsSettingsView
- All toggles persist immediately via `onChange` → `modelContext.save()`

---

## Badges & Achievements (31 badges)

- **Streak (6):** Rookie(3d), Getting Serious(10d), Locked In(50d), Triple Threat(100d), No Days Off(365d), Immortal(1000d)
- **Meals (6):** First Bite(1), Forking Around(5), Nutrition Novice(20), Mission Nutrition(50), The Logfather(500), Calorie Counter(1000)
- **Workouts (5):** First Rep(1), Gym Rat(10), Iron Addict(50), Beast Mode(100), Legendary(500)
- **Strength (5):** PR Breaker(1PR), PR Machine(10PR), PR Monster(50PR), Volume King(100K lbs), Million Pound Club(1M lbs)
- **Body/Progress (6):** Weigh In, Snapshot, Transformation, Goal Crusher, Perfect Week, Hydration Hero
- **Social (3):** Social Butterfly, Team Player, Influencer

### Badge Earning Flow
1. `FuelLiftApp.swift` creates `BadgeViewModel` → `initializeBadgesIfNeeded()` on launch
2. `DashboardView.onAppear` → `recheckAllBadges()` (safety net — catches any missed badges)
3. `NutritionViewModel.addFoodEntry()` → `checkMealBadges()` + `checkStreakBadges()`
4. `WorkoutViewModel.finishWorkout()` → `checkWorkoutBadges()` + `checkPRBadges()`
5. `awardBadge()` auto-reloads badges if empty, sets earnedDate, triggers confetti + toast
6. **MilestonesView** — tap any badge → NavigationLink → BadgeDetailView
7. **BadgeDetailView** — shows large image (greyed out for locked), requirement, earned date, share button
8. **BadgeGridItem** — earned: full color + orange glow border, locked: desaturated + lock overlay

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
- **Signing:** Manual code signing on FuelLift target only; SPM packages use automatic
- **Secrets:** ANTHROPIC_API_KEY, OPENAI_API_KEY, GEMINI_API_KEY, DEVELOPMENT_TEAM, MATCH_*, ASC_*
- **App Icon:** Pixel art lifter character, 1024x1024 PNG (single-size format)

---

## Current Dev Status

- **Firebase:** Disabled. All services guard with `FirebaseApp.app() != nil`.
- **Auth:** Bypassed — isAuthenticated = true on init.
- **Local data:** SwiftData fully functional.
- **Gemini AI:** Active — food photo scanning, food description analysis, Fix Issue reprompt (key: GEMINI_API_KEY).
- **Claude AI:** Active — workout plans, nutrition goals (key: ANTHROPIC_API_KEY).
- **HealthKit:** Active — steps + active calories fetched for dashboard (requires device support).
- **UI:** Retro-futuristic adaptive — dark arcade (#08080F) or clean light (#F7F7F9), hot orange accents (#FF6B00), neon macro colors, pixel-stepped borders, CRT scanline overlay, glow effects. 123 custom pixel art assets. `.pixelArt()` helper on all asset images.
- **Appearance:** Auto/Light/Dark via visual card picker in Preferences. Colors adapt using UIColor dynamic provider.
- **Build:** Compiles cleanly (0 errors). CI/CD fully operational.
- **TestFlight:** Live, internal testing.

### Known Warnings
- HKWorkout init deprecated iOS 17 (HealthKitService)
- Unused StorageReference (StorageService)
- "All interface orientations must be supported" (build warning, non-blocking)

### Recently Implemented (v8 — Cal AI-Inspired Feature Overhaul)
- **Swipeable 3-page dashboard** — TabView pager: Calories+Macros → Steps+Burned → Water tracker
- **Scrollable 3-week calendar** — WeekDaySelector rewritten with ScrollViewReader, 21 days, month labels
- **Instant food add** — camera dismisses immediately, shimmer placeholder card, background Gemini analysis
- **Fix Issue AI reprompt** — FixIssueSheet with text description, calls correctFoodAnalysis(), updates entry
- **AI feedback** — thumbs up/down on FoodEntryDetailView, persists to FoodEntry.aiFeedback
- **Shimmer loading cards** — animated shimmer modifier for pending food entries on dashboard
- **Context menu delete** — long-press food entry cards to delete from dashboard
- **Preferences redesign** — visual appearance card picker (mini previews), 4 new feature toggles
- **HealthKit dashboard integration** — steps + active calories burned fetched and displayed
- **New model fields** — FoodEntry: analysisStatus, aiFeedback; UserProfile: enableBadgeCelebrations, enableLiveActivity, addBurnedCalories, rolloverCalories
- **New files** — DashboardPagerView, StepsBurnedPage, WaterPage, FixIssueSheet
- **New gradients** — stepsRing, burnedRing, waterRing

### Previously Implemented (v7 — Gemini Vision + Light Mode)
- Gemini Vision food scanning, JSON mode, light mode support, appearance setting

### Previously Implemented (v6 — Retro-Futuristic Dark UI + Badge System)
- Dark design system overhaul, badge system fixes, tappable badges, settings fixes

### Previously Implemented (v5 — Pixel Art Visual Overhaul)
- 122 pixel art assets, custom tab bar, app icon

### Deferred Features
- **Widgets + Live Activity + Dynamic Island** — requires Apple Developer Portal setup (App Groups, widget target)
- **Firebase Integration** — Re-enable Auth, Firestore sync, Storage
- **Custom Exercise Creation** — `isCustom` flag exists but no creation UI
- **Superset/Dropset Support** — SupersetGroupView exists but not integrated
- **Rest Timer Customization** — Needs user-configurable duration
- **Workout Sharing** — Export/import routines

---

## File Count Summary

| Directory | Files |
|-----------|-------|
| App | 3 |
| Models | 11 |
| ViewModels | 10 |
| Views | 55 (added 4 new) |
| Components | 9 |
| Services | 11 |
| Utilities | 4 |
| Resources | 5 |
| Scripts | 3 |
| Asset Images | 123 |
| **Total Swift** | **100** |
