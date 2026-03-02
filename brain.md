# FuelLift Brain - Complete Project Context

> Last updated: 2026-03-01 (v11 — AI Restaurant Ranking, AI Menu Scoring, 60+ Restaurants)
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
│   └── ContentView.swift   # Custom 5-tab bar + FAB overlay + scanline CRT
├── Models/                 # SwiftData @Model + structs (14 files)
│   └── FuelFinder/         # Restaurant, MenuItem, MenuItemScore (3 files)
├── ViewModels/             # State managers (12 files)
│   ├── FuelFinderViewModel.swift
│   └── FuelFinderSurveyViewModel.swift (v10 NEW)
├── Views/                  # SwiftUI views (65 files)
│   ├── Dashboard/          # 6 files
│   ├── Nutrition/          # 12 files (FoodScannerView)
│   ├── FuelFinder/         # 7 files (v10: added FuelFinderSurveyView, FuelFinderMapView)
│   ├── Workout/            # 10 files
│   ├── Progress/           # 12 files
│   ├── Social/             # 5 files
│   ├── Settings/           # 5 files
│   └── Onboarding/         # 3 files
├── Services/               # Singletons (15 files)
│   ├── GooglePlacesService.swift
│   ├── SpoonacularService.swift
│   ├── FuelFinderService.swift
│   └── LocationService.swift
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

5 tabs + Floating Action Button (custom VStack-based, NOT SwiftUI TabView):

| Tab | Icon Asset | Destination | Purpose |
|-----|------------|-------------|---------|
| Home | icon_house | DashboardView | Daily summary, calorie ring, macros, streak |
| Progress | icon_chart_bar | ProgressDashboardView | Weight/calorie charts, milestones, badges |
| FuelFinder | SF: mappin.and.ellipse | FuelFinderView | Nearby restaurants, menu nutrition, goal scoring |
| Workout | icon_dumbbell | WorkoutListView | Templates, active workout, history |
| Profile | icon_person | SettingsView | Profile, settings, social access |

- **Tab bar design:** Dark bg, orange gradient top line, glowing 3px orange underline on selected tab, spring animation, icon scale 1.1x on select
- **FAB:** Orange FloatingActionButton bottom-right with glow + ring border, opens FoodLogView sheet
- **CRT overlay:** Scanline pattern on content area
- FuelFinder tab uses SF Symbol (useSFSymbol property on Tab enum)

---

## Models (SwiftData @Model)

### UserProfile
- Goals: calorieGoal (2000), proteinGoal (150g), carbsGoal (250g), fatGoal (65g), waterGoalML (2500)
- Body: heightCM, weightKG, weightGoalKG (optional), age, gender, activityLevel
- Nutrition Plan: dietaryPreference (String?), workoutsPerWeek (Int?), targetWeightKG (Double?)
- Prefs: useMetricUnits, darkModeEnabled (legacy), notificationsEnabled, healthKitEnabled
- **Appearance:** appearanceMode (String, default "auto") — "auto", "light", "dark"
- **Feature Toggles (v8):** enableBadgeCelebrations (true), enableLiveActivity (false), addBurnedCalories (false), rolloverCalories (false)
- **FuelFinder Survey (v10):** hasFuelFinderSurvey (Bool), fuelFinderDietType (String), fuelFinderCuisinePreferences (JSON string), fuelFinderProteinPreferences (JSON string), fuelFinderAllergies (JSON string). Computed helpers: cuisinePreferencesArray, proteinPreferencesArray, allergiesArray (get/set [String]).
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

### FuelFinder Models (v10 — plain structs, not SwiftData)
- **Restaurant** — id (placeId), name, address, coordinate (CLLocationCoordinate2D), distanceMeters, isOpen, photoReference, priceLevel, rating, userRatingsTotal, types. Computed: distanceText, priceLevelText. Hashable via id only.
- **MenuItem** — id, name, restaurantChain, servingSize, calories, proteinG, carbsG, fatG, imageURL, badges, source (MenuItemSource: .spoonacular | .geminiEstimate), **imageSearchQuery** (String?), **healthScore** (Int? 0-100), **description** (String?), **userMatchScore** (Int? 0-100, AI personalized), **userMatchRationale** (String?, AI explanation). `macroSummary` uses Int() — no decimals.
- **MenuItemScore** — score (0-100), label (GREAT/GOOD/FAIR/POOR), color. **v11: AI-first scoring** — `fromAI(score:rationale:)` creates scores from Gemini-provided values. `calculate(item:profile:)` checks `item.userMatchScore` first (AI path), falls back to healthScore-based adjustments. Matches "Lose Fat"/"Build Muscle" in addition to "weight_loss"/"muscle_gain".

### Supporting Types
- **BadgeCategory** (enum) — streak, meals, workouts, strength, bodyProgress, social (displayName, gradientColors, gradient)
- **BadgeKey** (enum) — 31 cases across 6 categories
- **BadgeDefinition** (struct) — static all: 31 badge definitions with keys, names, icons, requirements, imageName
- **PRType** (enum) — oneRM, volume, weight (label, color)
- **ScanMode** (enum) — scanFood, barcode, foodLabel (rawValue + iconName SF Symbol)

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
| FuelFinderViewModel | ObservableObject | restaurants, selectedRestaurant, menuItems, scoredItems, isLoadingRestaurants, isLoadingMenu, searchText, selectedFilter (MenuFilter), **viewMode (list/map)**, **showSurvey**, **showResetAlert**, **mapCameraPosition**, **mapCenter**, **showSearchThisArea**, **currentProfile** | loadRestaurants(profile:) **(v11: AI-ranks restaurants via Gemini)**, **searchRestaurants()** (debounced 500ms text search + AI ranking), selectRestaurant(), addToFoodLog(), **checkSurvey()**, **resetSurvey()** (v11: immediately re-shows survey), **searchThisArea()** (v11: AI-ranks), **onMapCameraChange()**, **initializeMapPosition()** — **uses GooglePlaces (nearby + text search), Gemini AI ranking, Location** |
| FuelFinderSurveyViewModel | ObservableObject | selectedDietType, selectedCuisines, selectedProteins, selectedAllergies, dietTypes, cuisineOptions, proteinOptions, allergyOptions | saveSurvey(profile:context:), loadExisting(profile:) — **(v10 NEW)** |
| SocialViewModel | ObservableObject | groups, friends | — Firebase dependent |

---

## Dashboard (v8/v9)

### Layout (DashboardView.swift)
1. **Header** — logo + StreakBadge (if streak > 0)
2. **WeekDaySelector** — scrollable 21-day (3 weeks back) horizontal ScrollViewReader, auto-scrolls to selected date, month labels on week boundaries
3. **DashboardPagerView** — swipeable 3-page TabView with page dots:
   - Page 1: CalorieSummaryCard (calorie ring + macro rings)
   - Page 2: StepsBurnedPage (steps + active calories from HealthKit, dual progress rings)
   - Page 3: WaterPage (water ring + add buttons)
4. **Quick Actions** — Scan Food, Start Workout, AI Nutrition Plan
5. **WorkoutSummaryCard** — today's completed workout
6. **Recently Uploaded** — food list with shimmer cards for pending entries, swipe-to-delete

### Swipe-to-Delete (v9)
- Per-entry offset tracking via `@State private var swipeOffsets: [String: CGFloat]`
- DragGesture with `minimumDistance: 30`, horizontal-priority detection (`abs(horizontal) > abs(vertical)`)
- Reveals red delete button behind card at -90pt offset
- Spring animation on snap/reset

### Instant Food Add Flow (v9 — CalAI Camera)
1. User taps "Scan Food" → FoodScannerView opens fullScreenCover
2. Live AVCaptureSession preview with corner brackets, mode tabs, shutter button
3. Three modes: Scan Food (photo capture), Barcode (AVCaptureMetadataOutput), Food Label (photo capture)
4. Photo captured → dismiss → pending FoodEntry created (analysisStatus="pending")
5. Dashboard shows shimmer card with food thumbnail
6. Gemini analysis runs in background via Task.detached (survives view dismissal)
7. On completion → entry updated, shimmer resolves to real card
8. On failure → analysisStatus="failed", name="Analysis failed"
9. Auto-refresh timer (2s) re-fetches while entries are pending
10. Barcode mode → BarcodeService lookup in background, same shimmer flow

---

## FuelFinder (v10 — Major Overhaul)

### Overview
Finds nearby restaurants via Google Places API (**v11: 4 parallel searches — DISTANCE + POPULARITY + café/delivery + wider radius — for 60+ results**), **AI-ranks restaurants by fitness suitability via Gemini**, shows personalized menu items with deep Gemini AI research (20 items, 120s timeout, user dietary preferences, **per-item AI match score + rationale**), supports real text search, includes interactive map with restaurant pins.

### AI Dietary Survey (v10 NEW)
- **FuelFinderSurveyView** — 4-step TabView wizard (same pattern as WorkoutPlannerView):
  - Step 1: Diet type (Omnivore/Vegetarian/Vegan/Pescatarian/Keto/Halal/Kosher)
  - Step 2: Cuisine preferences (multi-select: Indian, Mexican, Italian, Chinese, etc.)
  - Step 3: Protein preferences (multi-select: Chicken, Beef, Fish, etc. — skipped if Vegan)
  - Step 4: Allergies (multi-select: Gluten, Dairy, Nuts, etc.)
- Shown as fullScreenCover on first FuelFinder visit (profile.hasFuelFinderSurvey == false)
- Data saved to UserProfile FuelFinder fields (JSON-encoded arrays)
- "Reset Preferences" gear button at top of FuelFinderView → confirmation alert → clears survey

### Services
- **LocationService** — `@MainActor` ObservableObject wrapping CLLocationManager. `@Published currentLocation`, `authorizationStatus`. Uses `nonisolated` delegate + `Task { @MainActor in }` pattern.
- **GooglePlacesService** — Singleton. **v11: 4 parallel nearby searches** (DISTANCE + POPULARITY + cafe/meal_delivery/meal_takeaway + wider radius POPULARITY) merged/deduped for **60+ results**. **Text Search API** via `searchRestaurantsByText()` (`POST /v1/places:searchText`). **Non-restaurant filter** (excludes movie_theater, bowling_alley, gas_station, etc.). **Quality sorting** by `rating * ln(reviews+1) * openBonus`. `photoURL(reference:maxWidth:)` builds media URL.
- **SpoonacularService** — Singleton. GET `/food/menuItems/search` for image enrichment. Handles 402 quota exceeded gracefully.
- **FuelFinderService** — Orchestrator. **v11: AI-first architecture.** `aiRankRestaurants()` sends restaurant list + user profile to Gemini for fitness-based ranking (fitness_score 0-100 per restaurant). **Deep Gemini research** as primary — 20 items, 120s timeout, personalized prompt with strict fitness nutritionist scoring (ice cream/junk → 0-25, grilled protein → 80-100). Returns userMatchScore (0-100), userMatchRationale, imageSearchQuery, healthScore, description per item. Spoonacular used only for image URL enrichment.

### Map Feature (v10 NEW)
- **FuelFinderMapView** — SwiftUI Map with MapKit, restaurant Annotation pins, UserAnnotation for current location
- **List/Map toggle** — Segmented picker at top of FuelFinderView switches between list and map
- **Restaurant pins** — Custom annotations with name, rating, open/closed color border (orange/red)
- **"Search This Area"** — Floating capsule button appears when user pans >500m, triggers new nearby search at map center
- **Pin tap** — NavigationLink to RestaurantDetailView
- **Map controls** — MapUserLocationButton, MapCompass

### Views
- **FuelFinderView** — Main tab. NavigationStack with search bar (debounced text search via Google Places Text Search API), List/Map toggle, survey fullScreenCover, reset preferences button, location prompt card, shimmer loading, restaurant list.
- **FuelFinderMapView** — Interactive map with restaurant annotation pins, "Search This Area" button (v10 NEW).
- **FuelFinderSurveyView** — 4-step dietary preference wizard (v10 NEW).
- **RestaurantCard** — AsyncImage for photo, rating stars, distance, open/closed pill, price level.
- **RestaurantDetailView** — Header photo, Map with pin, "Get Directions" button, filter pills, menu list, **v10: research loading state** ("Researching [name]..." with progress indicator, "This may take up to 2 minutes"), "AI Estimated" disclaimer.
- **MenuItemCard** — Food image, **integer macros (no decimals)**, score badge circle (0-100 colored by GREAT/GOOD/FAIR/POOR).
- **MenuItemDetailView** — Full nutrition display, **integer macros**, score rationale, meal type picker, "Add to Food Log" button → creates FoodEntry(source: "restaurant").

### API Keys
- `GOOGLE_PLACES_API_KEY` — separate from Gemini key, enabled on GCP project with Places API (New)
- `SPOONACULAR_API_KEY` — free tier (150 req/day)
- Both passed via: GitHub Secrets → Fastfile xcargs → project.yml → Info.plist → Constants.swift

### Constants (added)
- `googlePlacesAPIKey`, `googlePlacesBaseURL` ("https://places.googleapis.com/v1"), `googlePlacesNearbyRadiusMeters` (8000)
- `spoonacularAPIKey`, `spoonacularBaseURL` ("https://api.spoonacular.com")

### project.yml (added)
- `GOOGLE_PLACES_API_KEY: $(GOOGLE_PLACES_API_KEY)`, `SPOONACULAR_API_KEY: $(SPOONACULAR_API_KEY)`
- `NSLocationWhenInUseUsageDescription`

---

## CalAI-Style Camera Scanner (v9 — NEW)

### FoodScannerView (Views/Nutrition/FoodScannerView.swift)
Full-screen custom camera replacing UIImagePickerController. Matches CalAI's scanning UI:

- **Live preview** — AVCaptureSession with CameraPreviewView (UIViewRepresentable wrapping AVCaptureVideoPreviewLayer)
- **Corner brackets** — White CornerBracket shapes at four corners of scan area, pulsing animation
- **Scan area** — Tall rectangle (width-40 x 50% height), centered at 38% vertical
- **Top bar** — Close (X) button left, Help (?) button right, dark circle backgrounds
- **Zoom toggle** — `.5x` / `1x` capsule pills, calls `device.videoZoomFactor`
- **Mode tabs** — Three rounded rectangles with SF Symbol icons + labels:
  - Scan Food (viewfinder icon) — captures photo for Gemini analysis
  - Barcode (barcode icon) — AVCaptureMetadataOutput for EAN/UPC/Code128/QR
  - Food label (doc.text icon) — captures photo of nutrition label
- **Shutter button** — Large white circle with spring scale animation on tap
- **Flash toggle** — Bottom-left, toggles device.torchMode
- **Photo library** — Bottom-right, PhotosPicker for choosing from library
- **Bottom gradient** — Black gradient overlay behind controls

### CameraManager (@MainActor ObservableObject)
- Manages AVCaptureSession, AVCapturePhotoOutput, AVCaptureMetadataOutput
- `configure(mode:)` — sets up camera input + outputs, starts session on background queue
- `capturePhoto()` — AVCapturePhotoSettings with flash support
- `switchMode(_:)` — toggles barcode detection active/inactive
- `setZoom(_:)` — clamped videoZoomFactor
- `toggleFlash(_:)` — device.torchMode
- `nonisolated` delegate methods with `Task { @MainActor in }` pattern

---

## AI Services

### GeminiService (Food Scanning + FuelFinder Fallback)
- **File:** `Services/GeminiService.swift`
- **Singleton:** `GeminiService.shared`
- **Model:** `gemini-2.5-flash` (stable, text+vision)
- **API:** REST direct (no SDK), API key as query param
- **Methods:**
  - `analyzeFoodPhoto(_:)` → `NutritionData`
  - `analyzeFoodDescription(_:)` → `NutritionData`
  - `correctFoodAnalysis(original:issue:image:)` → `NutritionData` **(v8 — Fix Issue reprompt)**
- **Features:** `responseMimeType: "application/json"` + `responseSchema` for clean JSON, 60s timeout, fallback Int/Double decoding, safety filter detection
- **Image handling:** Images downscaled to 1024px max dimension before upload to avoid timeouts

### ClaudeService (Workout Plans & Nutrition Goals)
- **File:** `Services/ClaudeService.swift`
- **Singleton:** `ClaudeService.shared`
- **Model:** `claude-sonnet-4-6`
- **API:** Anthropic REST API with `x-api-key` header
- **Methods:** `generateWorkoutPlan()`, `refineWorkoutPlan()`, `calculateNutritionGoals()`
- **API Key:** `ANTHROPIC_API_KEY` via Info.plist → `AppConstants.anthropicAPIKey`

### API Key Chain (for all services)
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
- **Secrets:** ANTHROPIC_API_KEY, OPENAI_API_KEY, GEMINI_API_KEY, GOOGLE_PLACES_API_KEY, SPOONACULAR_API_KEY, DEVELOPMENT_TEAM, MATCH_*, ASC_*
- **Fastfile xcargs:** passes all 6 API keys + DEVELOPMENT_TEAM to build
- **App Icon:** Pixel art lifter character, 1024x1024 PNG (single-size format)

---

## Current Dev Status

- **Firebase:** Disabled. All services guard with `FirebaseApp.app() != nil`.
- **Auth:** Bypassed — isAuthenticated = true on init.
- **Local data:** SwiftData fully functional.
- **Gemini AI:** Active — food photo scanning, food description analysis, Fix Issue reprompt, **FuelFinder deep menu research** (key: GEMINI_API_KEY). 60s timeout for food scan, **120s timeout for FuelFinder**. Image downscaling to 1024px.
- **Claude AI:** Active — workout plans, nutrition goals (key: ANTHROPIC_API_KEY).
- **Google Places:** Active — **nearby search (4 parallel calls: DISTANCE+POPULARITY+café/delivery+wider)** for 60+ results + **text search API** (key: GOOGLE_PLACES_API_KEY). Places API (New) POST endpoints.
- **Spoonacular:** Active — image URL enrichment for FuelFinder (key: SPOONACULAR_API_KEY). Free tier 150 req/day.
- **HealthKit:** Active — steps + active calories fetched for dashboard (requires device support).
- **Location:** Active — CLLocationManager for FuelFinder tab (NSLocationWhenInUseUsageDescription).
- **UI:** Retro-futuristic adaptive — dark arcade (#08080F) or clean light (#F7F7F9), hot orange accents (#FF6B00), neon macro colors, pixel-stepped borders, CRT scanline overlay, glow effects. 123 custom pixel art assets. `.pixelArt()` helper on all asset images.
- **Appearance:** Auto/Light/Dark via visual card picker in Preferences. Colors adapt using UIColor dynamic provider.
- **Build:** CI/CD fully operational.
- **TestFlight:** Live, internal testing.

### Known Warnings
- HKWorkout init deprecated iOS 17 (HealthKitService)
- Unused StorageReference (StorageService)
- "All interface orientations must be supported" (build warning, non-blocking)

### Recently Implemented (v11 — AI Restaurant Ranking, AI Menu Scoring, 60+ Restaurants)
- **AI Restaurant Ranking** — `aiRankRestaurants()` sends restaurant list + user profile to Gemini, gets fitness_score per restaurant, re-sorts by AI fitness suitability. Applied in loadRestaurants(), searchRestaurants(), and searchThisArea().
- **AI Menu Item Scoring** — Each menu item gets `userMatchScore` (0-100) and `userMatchRationale` from Gemini with strict fitness nutritionist rules (ice cream → 0-25, grilled chicken → 80-100). MenuItemScore.fromAI() creates scores directly from Gemini values.
- **60+ Restaurants** — 4 parallel Google Places API calls (DISTANCE + POPULARITY + cafe/delivery/takeaway + wider radius) merged/deduped
- **Survey Reset Fix** — Reset now immediately re-shows the survey (was only clearing data without re-prompting)
- **MenuItem AI fields** — Added userMatchScore (Int?) and userMatchRationale (String?) to MenuItem model
- **Strict Scoring Prompt** — Gemini prompt explicitly penalizes junk food for fitness users, rewards lean proteins and balanced meals
- **All construction sites fixed** — FuelFinderService image merge, SpoonacularService, and deepGeminiResearch all pass the new MenuItem fields

### Previously Implemented (v10 — FuelFinder Overhaul: Survey, Map, Deep Research, Search)
- AI Dietary Survey (4-step wizard), Deep Gemini Menu Research (20 items, 120s, personalized), Interactive Map (pins + search this area), List/Map toggle, Real Text Search (Google Places), Non-restaurant filter, Quality sorting, Integer macros, Goal string bug fix, Reset Preferences, Research loading state, MenuItem enhancements (imageSearchQuery, healthScore, description)

### Previously Implemented (v9 — FuelFinder + CalAI Camera Scanner)
- FuelFinder tab, restaurant detail, menu scoring, Spoonacular integration, CalAI camera scanner, swipe-to-delete, barcode scanning, image downscaling, background analysis

### Previously Implemented (v8 — Cal AI-Inspired Feature Overhaul)
- Swipeable 3-page dashboard, scrollable 3-week calendar, instant food add, Fix Issue AI reprompt, AI feedback, shimmer loading, preferences redesign, HealthKit integration

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
| Models | 14 |
| ViewModels | 12 (added FuelFinderSurveyViewModel) |
| Views | 65 (added FuelFinderSurveyView, FuelFinderMapView) |
| Components | 9 |
| Services | 15 |
| Utilities | 4 |
| Resources | 5 |
| Scripts | 3 |
| Asset Images | 123 |
| **Total Swift** | **118** |
