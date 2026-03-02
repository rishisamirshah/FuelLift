Create a new API service following FuelLift's singleton service pattern.

The user will provide the service name and API. For example: `/new-service NutritionixAPI`

Steps:
1. Create the service at `FuelLift/FuelLift/Services/{Name}Service.swift`:
   - Import Foundation
   - Use singleton pattern: `static let shared = {Name}Service()`
   - Private init
   - Add the base URL as a constant
   - Add API key reference from Constants.swift if needed
   - Use async/await for all network calls
   - Return proper Swift types (decode JSON with Codable)
   - Handle errors gracefully with do/catch
   - Add timeout handling (follow GeminiService pattern: 60s default)

2. If the service needs an API key:
   - Add the key constant to `FuelLift/FuelLift/Utilities/Constants.swift`
   - Add the key to `FuelLift/FuelLift/Resources/Info.plist`
   - Add the xcargs injection in `FuelLift/project.yml` under build settings
   - Add to `FuelLift/fastlane/Fastfile` xcargs string
   - Note: user needs to add the secret to GitHub repo settings for CI/CD

Existing services for reference pattern:
- GeminiService.swift (AI analysis, 60s timeout, complex JSON parsing)
- GooglePlacesService.swift (REST API, API key auth, Codable response models)
- HealthKitService.swift (system framework, authorization flow)
- LocationService.swift (CLLocationManager delegate pattern)

All services are singletons accessed via `{Name}Service.shared`.
