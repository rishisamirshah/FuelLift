Add a new achievement badge to FuelLift's gamification system.

The user will describe the badge. For example: `/add-badge "Hydration Hero" - drink 8 glasses of water for 7 days straight`

Steps:
1. Read the existing badge definitions in `FuelLift/FuelLift/Models/Badge.swift` to understand the pattern and categories
2. Add the new badge to the Badge model/enum with:
   - Unique ID
   - Display name and description
   - Category (Streaks, Meals, Workouts, Strength, BodyProgress, Social)
   - Unlock condition/threshold
   - Rarity tier if applicable

3. Add the unlock logic in `FuelLift/FuelLift/ViewModels/BadgeViewModel.swift`:
   - Implement the check condition
   - Trigger badge unlock notification

4. Create a pixel art badge icon placeholder:
   - Note that the user needs to add a custom 8-bit pixel art image to `FuelLift/FuelLift/Resources/Assets.xcassets/badge_{name}.imageset/`
   - Follow the retro-futuristic art style (orange neon accents, dark background)

5. The badge will automatically appear in the Milestones grid view (`MilestonesView.swift`) via the existing BadgeGridItem component

Current badge count: 31 badges across 6 categories. Badge celebrations use ConfettiSwiftUI when enabled in user preferences.
