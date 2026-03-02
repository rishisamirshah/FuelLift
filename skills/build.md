Generate the Xcode project using XcodeGen and build the FuelLift app.

Steps:
1. Run `xcodegen generate` in the `FuelLift/` directory to regenerate `FuelLift.xcodeproj` from `project.yml`
2. Run `xcodebuild -project FuelLift/FuelLift.xcodeproj -scheme FuelLift -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build` to build
3. Report any build errors with file paths and line numbers
4. If there are SPM resolution issues, suggest running `xcodebuild -resolvePackageDependencies` first

The project uses these SPM dependencies: Firebase (≥11.0.0), Lottie (≥4.4.0), SwiftUI-Shimmer (≥1.4.0), ConfettiSwiftUI (≥1.1.0).

Bundle ID: com.fuellift.app | Min iOS: 17.0 | Swift 5.9
