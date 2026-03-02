Build and run FuelLift in the iOS Simulator.

Steps:
1. Ensure the Xcode project is up to date: `cd FuelLift && xcodegen generate`
2. List available simulators: `xcrun simctl list devices available | grep iPhone`
3. Build and run on the specified simulator (default: iPhone 16 Pro):
   ```
   xcodebuild -project FuelLift.xcodeproj -scheme FuelLift \
     -sdk iphonesimulator \
     -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
     build
   ```
4. If build succeeds, boot the simulator and install:
   ```
   xcrun simctl boot "iPhone 16 Pro"
   xcrun simctl install booted Build/Products/Debug-iphonesimulator/FuelLift.app
   xcrun simctl launch booted com.fuellift.app
   ```
5. If the user specifies a different device (e.g., "iPad Pro", "iPhone 15"), adjust the destination accordingly

Common issues:
- "No simulator found": run `xcodebuild -downloadPlatform iOS` to install simulator runtime
- Build fails: run `/fix-build` to diagnose
- Simulator won't boot: `xcrun simctl shutdown all` then try again

The app requires iOS 17.0+ so only use simulators with iOS 17 or later.
