# FuelLift - Claude Instructions

## Second Brain
**Always read `brain.md` at the start of every task.** It contains the full project context: architecture, models, views, services, build setup, and current dev status. Keep it updated when making significant changes.

## Project Setup
- **Build:** `xcodegen generate` then open `FuelLift.xcodeproj`
- **Run:** Cmd+R in Xcode (iOS 17+ simulator)
- **Firebase:** Currently disabled for local dev. All services guard `FirebaseApp.app() != nil`.
- **Auth:** Bypassed — app loads directly to ContentView.

## Code Conventions
- SwiftUI + SwiftData (iOS 17+)
- MVVM: Views → ViewModels (@ObservableObject) → Services (singletons)
- Custom colors via `Color.appCalories`, `Color.appProtein`, etc. — always use explicit `Color.` prefix in `foregroundStyle()` contexts
- Card styling via `.cardStyle()` modifier
- Services use singleton pattern (`static let shared`)
- HealthKit uses `HKStatisticsQueryDescriptor` with `.quantitySample(type:predicate:)` pattern

## Update All Task
When asked to "update all" or refresh brain.md, use agent teams with 4-5 agents to scan:
1. Models — all @Model classes, structs, enums
2. Views — all view files across 7 subdirectories
3. ViewModels + Services — all state managers and API integrations
4. Config + Utilities — project.yml, constants, extensions, build setup
5. Current status — build errors, Firebase state, known issues

Merge all findings into `brain.md` with the current date.
