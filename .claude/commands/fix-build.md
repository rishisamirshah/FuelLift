Diagnose and fix FuelLift build errors.

When the user encounters build errors, follow this systematic approach:

Steps:
1. Run `cd FuelLift && xcodegen generate` to regenerate the project from project.yml
2. Run `xcodebuild -project FuelLift.xcodeproj -scheme FuelLift -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build 2>&1` and capture all output
3. Parse the build output for errors. Common FuelLift issues:

   **SPM Resolution Failures:**
   - Run `xcodebuild -resolvePackageDependencies -project FuelLift.xcodeproj`
   - Clear derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData/FuelLift-*`

   **Missing Files:**
   - Check if file exists on disk but isn't in project.yml sources
   - Add to project.yml under the correct target → sources path

   **SwiftData @Model Errors:**
   - Ensure @Model classes have proper initializers
   - Check @Relationship and @Attribute usage
   - Verify model is registered in ModelContainer (FuelLiftApp.swift)

   **API Key / Info.plist Errors:**
   - Check Constants.swift reads from Bundle.main.infoDictionary
   - Verify project.yml has INFOPLIST_KEY entries

   **Type Mismatches After Refactoring:**
   - Check View ↔ ViewModel bindings
   - Verify @Observable class properties match View expectations

4. Fix each error, re-run the build, repeat until clean
5. Run `/test` after to ensure fixes didn't break tests
