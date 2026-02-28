# FuelLift UI Revamp — Full Implementation Plan

## Context

FuelLift's current UI uses basic SwiftUI defaults — light `.ultraThinMaterial` cards, system colors, and minimal visual hierarchy. The goal is to transform the entire app to match the premium aesthetic of **Cal AI** (for nutrition/dashboard/progress) and **Strong** (for workout tracking), creating a polished, App Store-ready product.

Reference screenshots analyzed: 22 images in `FuelLiftCalAiPlanRefrence/` directory. **All agents MUST read these images before starting work.**

### Reference Image Map (FuelLiftCalAiPlanRefrence/)

| Image | App | Screen | Agents That Need It |
|-------|-----|--------|-------------------|
| IMG_8874.PNG | Cal AI | **Home dashboard** — week selector, calorie ring, macro rings, streak badge, recently uploaded, tab bar | dashboard-nutrition, design-system |
| IMG_8875.PNG | Cal AI | **Progress top** — streak fire, badges earned, current weight, weight chart | progress-profile, badges-achievements |
| IMG_8876.PNG | Cal AI | **Milestones page** — badge grid (unearned=stars) | badges-achievements |
| IMG_8877.PNG | Cal AI | **Milestones scrolled** — earned badges (colored hex icons) | badges-achievements |
| IMG_8878.PNG | Cal AI | **Edit Weight** — ruler picker, imperial/metric toggle | progress-profile, onboarding-social |
| IMG_8879.PNG | Cal AI | **Progress scrolled** — weight chart, weight changes table | progress-profile |
| IMG_8880.PNG | Cal AI | **Progress more** — weight changes, progress photos CTA, daily avg calories | progress-profile |
| IMG_8881.PNG | Cal AI | **Nutrition charts** — stacked bar chart (protein/carbs/fats), weekly tabs, weekly energy | progress-profile, dashboard-nutrition |
| IMG_8882.PNG | Cal AI | **Weekly Energy** — burned vs consumed bar chart, expenditure changes | progress-profile |
| IMG_8883.PNG | Cal AI | **BMI card** — colored gauge bar, expenditure changes | progress-profile |
| IMG_8884.PNG | Cal AI | **Profile page** — avatar, premium badge, account sections, goals & tracking | onboarding-social, progress-profile |
| IMG_8886.PNG | Strong | **Start Workout** — empty workout CTA, template cards grid | workout |
| IMG_8887.PNG | Strong | **Exercise library** — A-Z list, search, body part + category filters | workout |
| IMG_8888.PNG | Strong | **Exercise detail: About** — illustration, instructions | workout |
| IMG_8889.PNG | Strong | **Exercise detail: History** — set tables by workout date, PR badges | workout |
| IMG_8890.PNG | Strong | **Exercise detail: Charts** — 1RM, max weight, volume trend charts | workout |
| IMG_8891.PNG | Strong | **Exercise detail: Records** — 1RM, weight, volume records, predicted table | workout |
| IMG_8892.PNG | Strong | **Body part filter dropdown** — Core, Arms, Back, Chest, Legs, etc. | workout |
| IMG_8893.PNG | Strong | **Category filter dropdown** — Barbell, Dumbbell, Machine, etc. | workout |
| IMG_8894.PNG | Strong | **Sort options** — Name, Frequency, Last Performed | workout |
| IMG_8895.PNG | Strong | **Workout History** — cards with duration, volume, PRs, exercise best sets | workout |
| IMG_8896.PNG | Strong | **Calendar view** — monthly grid with green checkmarks | workout |

**IMPORTANT:** Each agent prompt must include: "Before starting, read the reference images assigned to you in `FuelLiftCalAiPlanRefrence/` and match their visual style precisely."

### Key User Decisions
- **Tab structure:** 4 tabs + floating action button (Home, Progress, Workout, Profile)
- **Theme:** Full light AND dark mode support (system adaptive), not dark-only
- **Units:** lbs only, calories (not kcal) — US-focused app
- **Workout weights:** All set logging, PRs, and records display in lbs

---

## Design Language (extracted from screenshots)

### Cal AI Style (Dashboard, Nutrition, Progress, Profile)
- **System adaptive theme** — dark mode: black bg (#000000) + dark gray cards (#1C1C1E); light mode: white bg + light gray cards
- **Circular progress rings** for calories + individual macro rings (protein/carbs/fat)
- **Week day selector** — horizontal row with circular day badges, filled for logged days
- **Fire streak counter** badge in top-right corner
- **Stacked bar charts** (protein=blue, carbs=yellow/orange, fat=red) for weekly nutrition
- **Line charts** for weight with 90D/6M/1Y/ALL filter pills
- **Weight Changes table** — rows with mini colored bars + trend arrows (Increase/Decrease/No change)
- **Weekly Energy** — Burned vs Consumed bar chart with energy balance
- **BMI gauge** — horizontal colored bar (green=healthy, yellow=overweight, red=obese)
- **Milestones/Badges** — grid of hex-style badge icons (earned=colored, unearned=gray stars)
- **Progress Photos** — grid with upload CTA
- **Profile** — avatar, premium badge, grouped settings sections
- **Floating FAB** (+) button for adding meals
- **Tab bar** — Home, Progress, Groups, Profile (4 tabs)

### Strong Style (Workouts)
- **System adaptive** — follows user's light/dark mode preference
- **Template cards** — workout name, exercise list preview, last used date
- **"Start an Empty Workout"** prominent green CTA button
- **Exercise library** — A-Z scrollable index, search bar, body part + category filter dropdowns, sort options (Name/Frequency/Last Performed)
- **Exercise detail** — 4-tab layout (About/History/Charts/Records) with illustrations, set history tables, PR charts, predicted 1RM table
- **Workout history** — cards per workout showing duration, total volume, PR count, exercise best sets
- **Calendar view** — monthly grid with green checkmarks on workout days
- **PR badges** — colored pill badges (1RM teal, VOL green, WEIGHT yellow)

---

## UI Enhancement Libraries (add to project.yml)

These SPM packages will make the UI feel premium and polished:

| Package | Purpose | URL |
|---------|---------|-----|
| **Lottie** | Animated badges, streak fire, confetti on achievements | `https://github.com/airbnb/lottie-spm` |
| **SwiftUI-Shimmer** | Skeleton loading effects on cards while data loads | `https://github.com/markiv/SwiftUI-Shimmer` |
| **ConfettiSwiftUI** | Confetti explosion when earning badges or hitting goals | `https://github.com/simibac/ConfettiSwiftUI` |

---

## Badges & Achievements System

A full gamification layer with **30+ badges** across 5 categories:

### Streak Badges
| Badge | Requirement | Icon Concept |
|-------|-------------|--------------|
| Rookie | 3-day streak | Bronze flame |
| Getting Serious | 10-day streak | Silver flame |
| Locked In | 30-day streak | Gold flame |
| Triple Threat | 100-day streak | Platinum flame with sparkles |
| No Days Off | 365-day streak | Diamond flame |
| Immortal | 1000-day streak | Legendary rainbow flame |

### Meal Logging Badges
| Badge | Requirement | Icon Concept |
|-------|-------------|--------------|
| First Bite | Log 1 meal | Fork icon |
| Forking Around | Log 5 meals | Fork with sparkle |
| Nutrition Novice | Log 25 meals | Salad bowl |
| Mission Nutrition | Log 50 meals | Green bowl with glow |
| The Logfather | Log 500 meals | Crown + fork |
| Calorie Counter | Log 1000 meals | Calculator with flame |

### Workout Badges
| Badge | Requirement | Icon Concept |
|-------|-------------|--------------|
| First Rep | Complete 1 workout | Dumbbell |
| Gym Rat | Complete 25 workouts | Rat + dumbbell |
| Iron Addict | Complete 100 workouts | Iron plate |
| Beast Mode | Complete 250 workouts | Beast silhouette |
| Legendary | Complete 500 workouts | Trophy with glow |

### Strength PR Badges
| Badge | Requirement | Icon Concept |
|-------|-------------|--------------|
| PR Breaker | Hit first PR | Broken chain |
| PR Machine | Hit 10 PRs | Machine gear |
| PR Monster | Hit 50 PRs | Monster icon |
| Volume King | 100,000 lbs total volume | Crown |
| Million Pound Club | 1,000,000 lbs lifetime volume | Diamond trophy |

### Body/Progress Badges
| Badge | Requirement | Icon Concept |
|-------|-------------|--------------|
| Weigh In | Log first weight | Scale |
| Snapshot | Take first progress photo | Camera |
| Transformation | Log 30 days of weight | Butterfly |
| Goal Crusher | Hit calorie goal 7 days straight | Target |
| Perfect Week | Log all meals + workout for 7 days | Star |
| Hydration Hero | Hit water goal 7 days straight | Water drop |

### Social Badges
| Badge | Requirement | Icon Concept |
|-------|-------------|--------------|
| Social Butterfly | Join first group | People icon |
| Team Player | Complete 10 group challenges | Handshake |
| Influencer | Share 10 workouts | Share arrow |

Badges are stored as a `Badge` SwiftData model with: id, key (string enum), earnedDate (optional), category, requirement description. Unearned badges show as gray/locked. Earned badges show full color with earned date. Earning triggers a confetti animation + toast notification.

---

## Agent Team Structure

### Team: `ui-revamp`

**6 agents**, each working on a distinct area with no file conflicts:

### Agent 1: `design-system` (runs FIRST, blocks others)
**Role:** Build the shared design foundation that all other agents use.

**Files to create/modify:**
- `FuelLift/Utilities/Theme.swift` — NEW: Dark theme colors, typography scale, spacing constants
- `FuelLift/Utilities/Extensions.swift` — Update: new Color palette, enhanced `.cardStyle()`, new modifiers
- `FuelLift/Utilities/Components/` — NEW directory with shared components:
  - `ProgressRing.swift` — Reusable circular progress ring (used by dashboard + macros)
  - `WeekDaySelector.swift` — Horizontal scrollable day row with filled/unfilled states
  - `StreakBadge.swift` — Fire emoji + count badge
  - `TrendRow.swift` — Row with mini bar, value, trend arrow (for weight/energy changes)
  - `FilterPills.swift` — Horizontal selectable pill buttons (90D/6M/1Y/ALL, This wk/Last wk)
  - `FloatingActionButton.swift` — Circular FAB (+) positioned bottom-right
  - `BadgeGridItem.swift` — Hex badge for milestones (earned/unearned states)

**Design tokens to define (adaptive light/dark):**
```
Background:      dark=#000000       light=systemBackground
Card:            dark=#1C1C1E       light=systemGray6
CardSecondary:   dark=#2C2C2E       light=systemGray5
Accent:          orange (kept)
Protein:         #4A90D9 (blue)
Carbs:           #F5A623 (warm orange)
Fat:             #D0021B (red)
Calories:        #7ED321 (green)
Water:           #50E3C2 (teal)
Streak:          #FF9500 (orange-fire)
PR:              #00BCD4 (teal)
```
Use `Color(.systemBackground)` / `Color(uiColor:)` with adaptive UIColors so both modes work automatically.

---

### Agent 2: `dashboard-nutrition` (after design-system)
**Role:** Revamp Dashboard + all Nutrition views to Cal AI style.

**Files to modify (8 files):**
- `Views/Dashboard/DashboardView.swift` — Week day selector, calorie ring, macro rings, streak badge, recently uploaded section, floating FAB
- `Views/Dashboard/CalorieSummaryCard.swift` — Large calorie ring with remaining count center, 3 mini macro rings below
- `Views/Dashboard/WorkoutSummaryCard.swift` — Dark card with today's workout stats
- `Views/Nutrition/FoodLogView.swift` — Dark cards, meal sections with food item rows, water tracker
- `Views/Nutrition/CameraScanView.swift` — Dark overlay camera UI
- `Views/Nutrition/BarcodeScanView.swift` — Dark themed scanner
- `Views/Nutrition/FoodDetailView.swift` — Dark card form fields
- `Views/Nutrition/ManualFoodEntryView.swift` — Dark form styling

**Key UI changes:**
- Replace current calorie progress bar → circular ring with gradient stroke
- Add week day selector at top of dashboard
- Add streak fire badge (top-right)
- Macro display: 3 mini circular rings instead of horizontal bars
- "Recently uploaded" section showing last meals with food images
- Dark card backgrounds throughout
- Floating + button on dashboard for quick meal add

---

### Agent 3: `workout` (after design-system)
**Role:** Revamp all Workout views to Strong app style.

**Files to modify (7 files):**
- `Views/Workout/WorkoutListView.swift` — "Start Empty Workout" green button, template cards grid, workout history list
- `Views/Workout/ActiveWorkoutView.swift` — Clean set logging table, PR badge pills
- `Views/Workout/ExercisePickerView.swift` — Search + filter dropdowns (body part, category), sort menu, A-Z side index
- `Views/Workout/ExerciseDetailView.swift` — 4-tab layout (About/History/Charts/Records), set history tables, PR charts, predicted 1RM table
- `Views/Workout/RoutineEditorView.swift` — Template editor with exercise list
- `Views/Workout/RestTimerView.swift` — Dark overlay with large countdown
- `Views/Workout/SupersetGroupView.swift` — Paired exercise cards

**New files to create:**
- `Views/Workout/WorkoutCalendarView.swift` — Monthly grid with green checkmarks on workout days
- `Views/Workout/WorkoutHistoryCard.swift` — Card component: workout name, date, duration, volume, PRs, exercise best sets

**Key UI changes:**
- Template cards → 2-column grid showing exercise names + last used date
- Exercise picker → searchable list with body part/category dropdowns, A-Z index
- Exercise detail → tabbed view (About with instructions, History with set tables, Charts with 1RM/Volume/Weight trends, Records with predicted 1RM table)
- Active workout → clean white-on-dark set rows, PR pill badges (1RM teal, VOL green, WEIGHT yellow)
- History → chronological workout cards, calendar toggle

---

### Agent 4: `progress-profile` (after design-system)
**Role:** Revamp Progress dashboard, charts, milestones, and Profile/Settings to Cal AI style.

**Files to modify (10 files):**
- `Views/Progress/ProgressDashboardView.swift` — Streak + badges header, weight section, weight changes table, progress photos, daily avg calories chart, weekly energy chart, BMI card
- `Views/Progress/WeightChartView.swift` — Line chart with 90D/6M/1Y/ALL filter pills
- `Views/Progress/NutritionChartView.swift` — Stacked bar chart (protein/carbs/fat colored), weekly tabs
- `Views/Progress/StrengthChartView.swift` — PR list with better styling
- `Views/Progress/BodyMeasurementsView.swift` — Dark card measurements
- `Views/Progress/ProgressPhotosView.swift` — Grid with upload CTA card
- `Views/Settings/SettingsView.swift` — Profile header with avatar, grouped dark sections
- `Views/Settings/ProfileEditView.swift` — Dark form fields
- `Views/Settings/NotificationSettingsView.swift` — Dark toggle rows
- `Views/Settings/UnitsSettingsView.swift` — Dark segmented picker

**New files to create:**
- `Views/Progress/MilestonesView.swift` — Badge grid (streak badges, meal badges, earned/unearned)
- `Views/Progress/WeightChangesCard.swift` — Table with 3/7/14/30/90 day rows, mini bars, trend arrows
- `Views/Progress/WeeklyEnergyCard.swift` — Burned vs Consumed bar chart + energy balance
- `Views/Progress/BMICard.swift` — BMI value + colored gauge bar
- `Views/Progress/WeightEditorView.swift` — Full-screen weight picker with ruler slider, Imperial/Metric toggle

**Key UI changes:**
- Progress dashboard becomes a long scrolling page with all cards (Cal AI style)
- Streak + badges at top with fire animation
- Weight section: current weight, "Log weight" button, chart with filters, changes table
- Nutrition section: stacked bar charts with weekly tabs
- Energy section: burned vs consumed with balance
- BMI card with colored gauge
- Milestones page with badge grid (earned = colored, unearned = gray)

---

### Agent 5: `onboarding-social` (after design-system)
**Role:** Revamp Onboarding, Login, Social, and tab bar/navigation.

**Files to modify (8 files):**
- `App/ContentView.swift` — Update tab bar: 4 tabs (Home, Progress, Workout, Profile), orange tint, add floating action button
- `Views/Onboarding/LoginView.swift` — Themed, larger logo, refined Apple Sign-In button
- `Views/Onboarding/OnboardingView.swift` — Themed carousel with better imagery/icons
- `Views/Onboarding/GoalSetupView.swift` — Themed step wizard, ruler-style weight picker
- `Views/Social/GroupsListView.swift` — Themed group cards
- `Views/Social/GroupDetailView.swift` — Themed member list + leaderboard
- `Views/Social/LeaderboardView.swift` — Ranked list with gold/silver/bronze styling
- `Views/Social/WorkoutShareView.swift` — Shareable themed card design

**Key UI changes:**
- Tab bar: reduce from 5 to 4 tabs (Home, Progress, Workout, Profile) — Social accessible from Profile
- Themed onboarding flow with shimmer loading effects
- Goal setup uses ruler-style weight picker (like Cal AI's edit weight screen)

---

### Agent 6: `badges-achievements` (after design-system)
**Role:** Build the entire badges/achievements/gamification system from scratch.

**New files to create:**
- `Models/Badge.swift` — SwiftData @Model: id, key (BadgeKey enum), name, description, iconName, category (BadgeCategory enum), requirement, earnedDate (Date?), isEarned (computed)
- `Models/BadgeDefinitions.swift` — Static definitions of all 30+ badges with requirements and icon names
- `ViewModels/BadgeViewModel.swift` — Checks all badge conditions against user data, awards badges, triggers animations
- `Views/Progress/MilestonesView.swift` — Full-screen badge grid organized by category, earned vs unearned states, tap for detail
- `Views/Progress/BadgeDetailView.swift` — Badge detail: large icon, name, description, requirement, earned date, share button
- `Utilities/Components/BadgeGridItem.swift` — Single badge cell: icon (colored if earned, gray if locked), name, shimmer effect on newly earned
- `Utilities/Components/BadgeUnlockedOverlay.swift` — Full-screen celebration overlay with ConfettiSwiftUI + badge reveal animation
- `Utilities/Components/AchievementToast.swift` — Small toast notification that slides in when badge earned during normal app use

**Badge checking integration points (touch other agents' files — coordinate):**
- On meal log → check meal count badges
- On workout complete → check workout count + PR badges
- On streak update → check streak badges
- On weight log → check body/progress badges
- On water goal hit → check hydration badge

**Files to also modify:**
- `App/FuelLiftApp.swift` — Add Badge.self to ModelContainer schema
- `Models/` — Add Badge to schema list

---

### Agent 7: `frontend-polish-1` (Phase 3 — after all Phase 2 agents complete)
**Role:** Senior frontend engineer focused on **animations, transitions, and micro-interactions** across the entire app.

**Responsibilities:**
- Add smooth page transitions between tabs and navigation pushes (matched geometry effects)
- Animate calorie ring fill on appear (spring animation, countup number)
- Animate macro rings with staggered delays
- Streak badge fire pulse animation
- Card entrance animations (slide up with opacity fade, staggered for lists)
- Button press haptic feedback (UIImpactFeedbackGenerator) on key actions (log meal, complete set, earn badge)
- Pull-to-refresh animations on dashboard and food log
- Skeleton/shimmer loading states on every card using SwiftUI-Shimmer
- Tab bar transition animations
- FAB button expand animation (rotate + scale)
- Swipe-to-delete animation polish on food entries
- Rest timer countdown with circular animation
- PR celebration micro-animation (scale bounce + glow)

**Files touched:** All view files across the app (reads all, adds animation modifiers)

---

### Agent 8: `frontend-polish-2` (Phase 3 — after all Phase 2 agents complete)
**Role:** Senior frontend engineer focused on **layout polish, spacing, typography, and visual consistency** across the entire app.

**Responsibilities:**
- Audit every screen for consistent spacing (padding, card gaps, section margins)
- Typography hierarchy: ensure title/headline/subheadline/caption usage is consistent
- Card corner radius consistency (all cards 16pt, inner elements 12pt)
- Shadow and elevation consistency across light and dark modes
- Color contrast audit — ensure all text is readable in both modes (WCAG AA)
- Icon size consistency (tab bar, toolbar, inline icons)
- Empty state illustrations — consistent style for "no data yet" across all screens
- Form field styling consistency (all inputs, pickers, toggles look unified)
- Chart styling consistency (axis labels, grid lines, legend formatting)
- Safe area and notch handling — ensure no content clipped on any device
- Scroll behavior polish — rubber banding, sticky headers where appropriate
- Ensure all custom colors use explicit `Color.` prefix in `foregroundStyle()` contexts (known project requirement)

**Files touched:** All view files across the app (reads all, fixes spacing/typography/consistency)

---

## Execution Order

```
Phase 1 (blocking):
  └── design-system agent creates Theme.swift, shared components, updates Extensions.swift
  └── Also updates project.yml to add Lottie, SwiftUI-Shimmer, ConfettiSwiftUI packages

Phase 2 (parallel — all 5 agents run simultaneously):
  ├── dashboard-nutrition agent
  ├── workout agent
  ├── progress-profile agent
  ├── onboarding-social agent
  └── badges-achievements agent

Phase 3 (parallel — after Phase 2, polish pass):
  ├── frontend-polish-1 (animations + micro-interactions)
  └── frontend-polish-2 (layout + spacing + typography + consistency)
```

---

## Critical Files Summary

| Category | Agent | Files Modified | Files Created |
|----------|-------|---------------|---------------|
| Design System | `design-system` | 2 (Extensions.swift, project.yml) | ~9 (Theme.swift + 8 components) |
| Dashboard + Nutrition | `dashboard-nutrition` | 8 | 0 |
| Workout | `workout` | 7 | 2 |
| Progress + Profile | `progress-profile` | 10 | 5 |
| Onboarding + Social | `onboarding-social` | 8 | 0 |
| Badges & Achievements | `badges-achievements` | 1 (FuelLiftApp.swift) | 8 (model + VM + views + components) |
| Animations & Interactions | `frontend-polish-1` | ~30 (animation passes) | 0 |
| Layout & Consistency | `frontend-polish-2` | ~30 (polish passes) | 0 |
| **Total** | **8 agents** | **~60 file touches** | **~24 new files** |

---

## Verification

After all agents complete:
1. `xcodegen generate` to regenerate project
2. `xcodebuild -scheme FuelLift -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build` to verify zero errors
3. Run on simulator — walk through every tab and screen
4. Check for: dark backgrounds everywhere, no white flashes, correct colors, rings rendering, charts working, all navigation functional
5. Run `/update-all` to refresh brain.md with the new UI state
