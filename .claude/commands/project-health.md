Run a comprehensive health check on the FuelLift project.

Audit the following areas and report findings:

1. **Build Check**: Verify `project.yml` is valid and all referenced source files exist
   - Glob for all .swift files in FuelLift/FuelLift/ and compare against project.yml sources
   - Check for orphaned files not included in the project

2. **Asset Check**: Verify all referenced image assets exist in Assets.xcassets
   - Grep for image name strings in Swift files (e.g., Image("badge_xxx"))
   - Check each referenced image has a matching .imageset folder in Resources/Assets.xcassets

3. **API Key Check**: Verify Constants.swift has all required API keys and they're properly injected
   - Check: ANTHROPIC_API_KEY, GEMINI_API_KEY, GOOGLE_PLACES_API_KEY, SPOONACULAR_API_KEY
   - Verify Info.plist has the key placeholders
   - Verify project.yml has the xcargs for key injection

4. **Model Consistency**: Check all SwiftData @Model classes are registered in FuelLiftApp.swift ModelContainer

5. **Dead Code Detection**: Look for unused ViewModels, Views, or Services
   - Check if each ViewModel is referenced by at least one View
   - Check if each Service.shared is called somewhere

6. **Test Coverage**: List which ViewModels and Services have test coverage and which don't

7. **Dependency Check**: Verify SPM package versions in project.yml are up to date

Report as a checklist with pass/fail/warning status for each item.
