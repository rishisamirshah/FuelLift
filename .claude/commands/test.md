Run the FuelLift test suite (unit tests and UI tests).

Steps:
1. Run unit tests: `xcodebuild test -project FuelLift/FuelLift.xcodeproj -scheme FuelLift -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:FuelLiftTests`
2. If unit tests pass, run UI tests: `xcodebuild test -project FuelLift/FuelLift.xcodeproj -scheme FuelLift -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:FuelLiftUITests`
3. Parse test output and report: total tests, passed, failed, with failure details
4. If tests fail, read the failing test file and the source code it tests, then suggest fixes

Test files are in:
- `FuelLift/Tests/FuelLiftTests/FuelLiftTests.swift` (7 unit tests: JSON decoding, 1RM calc, exercise library)
- `FuelLift/Tests/FuelLiftUITests/FuelLiftUITests.swift` (1 UI test: app launch)
