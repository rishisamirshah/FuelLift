# FuelLift Brain - Complete Project Context

> Last updated: 2026-03-01 (v7 — Gemini Vision + Light Mode + Appearance Setting)
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
├── ViewModels/             # State managers (9 files)
├── Views/                  # SwiftUI views (51 files)
│   ├── Dashboard/          # 3 files
│   ├── Nutrition/          # 10 files
│   ├── Workout/            # 10 files
│   ├── Progress/           # 12 files
│   ├── Social/             # 5 files
│   ├── Settings/           # 5 files (added PreferencesView)
│   └── Onboarding/         # 3 files
├── Services/               # Singletons (9 files — added GeminiService)
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
- Settings UI: segmented picker (Auto / Light / Dark) in both SettingsView and PreferencesView

### View Modifiers (Extensions.swift)
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

### Image Helper
- `Image("name").pixelArt()` — `.resizable().renderingMode(.original).interpolation(.none).aspectRatio(contentMode: .fit)` (returns `some View`, chain `.frame()` after)

### Custom Shapes
- **PixelBorder** — stepped corner shape for retro card borders
- **ScanlinePattern** — horizontal line pattern for CRT overlay

### Gradients
- calorieRing, proteinRing, carbsRing, fatRing (color → 60% opacity)
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
- Dashboard toggles: showStreakBadge, showQuickActions, showMacrosBreakdown, showWaterTracker, showWorkoutSummary
- Streaks: currentStreak, longestStreak, lastLogDate
- Onboarding: hasCompletedOnboarding; Profile: displayName, email, firestoreId
- Reminder times: breakfastReminderHour/Minute, lunchReminderHour/Minute, dinnerReminderHour(18)/Minute(0)
- **Auto-created:** RootView creates default UserProfile on launch if none exists

### FoodEntry
- name, calories (Int), proteinG, carbsG, fatG, servingSize, mealType, date, imageData, barcode, source, firestoreId

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
| DashboardViewModel | ObservableObject | caloriesEaten, calorieGoal, macros, waterML, todayWorkout, currentStreak | loadDashboard(), calculateStreak() |
| NutritionViewModel | ObservableObject | selectedDate, todayEntries, todayWater, totals, badgeViewModel | addFoodEntry() (checks meal+streak badges) |
| WorkoutViewModel | ObservableObject | activeWorkout, exerciseGroups, elapsedSeconds, newPRs, badgeViewModel | startWorkout(), finishWorkout() (checks workout+PR badges) |
| ProgressViewModel | ObservableObject | weightHistory, calorieHistory, exercisePRs | loadData() |
| FoodScanViewModel | ObservableObject | capturedImage, scannedNutrition | analyzePhoto(), analyzeDescription() — **uses GeminiService** |
| WorkoutPlannerViewModel | ObservableObject | selectedGoal, generatedPlan | generatePlan(), savePlan(), refinePlan() — **uses ClaudeService** |
| ExerciseLibraryViewModel | ObservableObject | exercises, searchText | filteredExercises |
| SocialViewModel | ObservableObject | groups, friends | — Firebase dependent |

---

## AI Services

### GeminiService (Food Scanning — NEW)
- **File:** `Services/GeminiService.swift`
- **Singleton:** `GeminiService.shared`
- **Model:** `gemini-2.5-flash` (stable, text+vision)
- **API:** REST direct (no SDK), API key as query param
- **Methods:** `analyzeFoodPhoto(_:)`, `analyzeFoodDescription(_:)` → `NutritionData`
- **Features:** `responseMimeType: "application/json"` + `responseSchema` for clean JSON, 30s timeout, fallback Int/Double decoding, safety filter detection
- **API Key:** `GEMINI_API_KEY` via Info.plist → `AppConstants.geminiAPIKey`

### ClaudeService (Workout Plans & Nutrition Goals)
- **File:** `Services/ClaudeService.swift`
- **Singleton:** `ClaudeService.shared`
- **Model:** `claude-sonnet-4-6`
- **API:** Anthropic REST API with `x-api-key` header
- **Methods:** `generateWorkoutPlan()`, `refineWorkoutPlan()`, `calculateNutritionGoals()` (food scanning removed — moved to Gemini)
- **API Key:** `ANTHROPIC_API_KEY` via Info.plist → `AppConstants.anthropicAPIKey`

### API Key Chain (for both services)
GitHub Secrets → testflight.yml env → Fastfile xcargs → project.yml build settings → Info.plist → Bundle.main.infoDictionary → Constants.swift

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
- **Gemini AI:** Active — food photo scanning, food description analysis (key: GEMINI_API_KEY in Constants.swift).
- **Claude AI:** Active — workout plans, nutrition goals (key: ANTHROPIC_API_KEY in Constants.swift).
- **HealthKit:** Active (requires device support).
- **UI:** Retro-futuristic adaptive — dark arcade (#08080F) or clean light (#F7F7F9), hot orange accents (#FF6B00), neon macro colors, pixel-stepped borders, CRT scanline overlay, glow effects. 123 custom pixel art assets. `.pixelArt()` helper on all asset images.
- **Appearance:** Auto/Light/Dark via segmented picker in Settings. Colors adapt using UIColor dynamic provider.
- **Build:** Compiles cleanly (0 errors). CI/CD fully operational.
- **TestFlight:** Live, internal testing.

### Known Warnings
- HKWorkout init deprecated iOS 17 (HealthKitService)
- Unused StorageReference (StorageService)
- "All interface orientations must be supported" (build warning, non-blocking)

### Recently Implemented (v7 — Gemini Vision + Light Mode)
- **Gemini Vision food scanning** — GeminiService.swift replaces Claude for food photo/description analysis
- **JSON mode** — responseMimeType + responseSchema for reliable Gemini JSON output
- **Light mode support** — all Theme colors adaptive via UIColor dynamic provider
- **Appearance setting** — Auto/Light/Dark segmented picker replaces broken dark mode toggle
- **UserProfile.appearanceMode** — new property (default "auto"), applied in RootView.preferredColorScheme
- **Card shadows** — subtle shadow on cardStyle/secondaryCardStyle for light mode depth

### Previously Implemented (v6 — Retro-Futuristic Dark UI + Badge System)
- **Dark design system overhaul** — replaced system-adaptive colors with intentional dark palette
- **New color tokens** — neon macro colors, border/glow tokens, accent variants
- **New view modifiers** — pixelButtonStyle, primaryButtonStyle, accentGlow, scanlineOverlay, pixelCardStyle, PixelBorder shape, ScanlinePattern
- **`.pixelArt()` helper** — replaces verbose 4-line image rendering chain (50+ replacements across all views)
- **Tab bar redesign** — custom VStack with glowing orange underline indicator, spring animations, icon scale on select
- **Badge system fixes** — recheckAllBadges() on dashboard appear, auto-reload badges if empty in awardBadge
- **Tappable badges** — MilestonesView badges link to BadgeDetailView, locked badges show greyed-out image + lock overlay
- **Settings fixes** — NavigationStack added (fixes navigation), PreferencesView (dark mode, units, water goal), nutrition goals in ProfileEditView, "Reset AI Plan" rename
- **Exercise library expansion** — 18 new exercises (45 total), image mapping fixes
- **Exercise images in workout views** — thumbnails in ExercisePickerView (40x40) and ActiveWorkoutView (32x32)

### Previously Implemented (v5 — Pixel Art Visual Overhaul)
- 122 pixel art assets via Gemini Nano Banana, background removal, content cropping
- Custom tab bar replacing SwiftUI TabView (fixes icon sizing)
- App icon, logo, badge artwork, exercise illustrations

### Gemini Image Generation
- **Script:** `scripts/generate_image.py` — Python, `google-genai` SDK
- **Model:** Nano Banana (`gemini-2.5-flash-image`)
- **API Key:** Set via env var `GEMINI_API_KEY` (NOT hardcoded — previous key was leaked)
- **Usage:** `python generate_image.py "prompt" -o output.png -m nano [--raw]`
- **Models:** `nano` (default), `pro` (high quality), `nano2` (latest)

### Deferred Features
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
| Views | 51 |
| Components | 9 |
| Services | 11 (added GeminiService) |
| Utilities | 4 |
| Resources | 5 |
| Scripts | 3 (generate_image, remove_backgrounds, crop_images) |
| Asset Images | 123 |
| **Total Swift** | **96** |
