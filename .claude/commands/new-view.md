Scaffold a new SwiftUI View + ViewModel pair following FuelLift's architecture patterns.

The user will provide the feature name. For example: `/new-view MealPlan`

Steps:
1. Create the ViewModel at `FuelLift/FuelLift/ViewModels/{Name}ViewModel.swift`:
   - Import SwiftUI and SwiftData
   - Use @Observable class pattern (iOS 17+)
   - Add @Environment(\.modelContext) for SwiftData access
   - Include published properties for loading states, error handling
   - Follow the pattern in existing ViewModels like `DashboardViewModel.swift`

2. Create the View at `FuelLift/FuelLift/Views/{Category}/{Name}View.swift`:
   - Import SwiftUI
   - Use @State for the ViewModel
   - Apply FuelLift's retro-futuristic theme:
     - Background: Theme.Colors.background (#08080F)
     - Accent: Theme.Colors.accent (#FF6B00)
     - Card style: .cardStyle() modifier
     - Use Theme.Spacing, Theme.Typography from Utilities/Theme.swift
   - Add navigation title

3. Update `project.yml` if needed to include new files in the FuelLift target sources

Design system reference (from Utilities/Theme.swift):
- Colors: background (#08080F), cardBackground (#12121A), accent (#FF6B00), textPrimary (#F5F5F7)
- Macro colors: protein (blue), carbs (orange), fat (red), calories (green)
- Spacing: xs(4), sm(8), md(16), lg(24), xl(32)
- Corner radius: small(8), medium(12), large(16)
