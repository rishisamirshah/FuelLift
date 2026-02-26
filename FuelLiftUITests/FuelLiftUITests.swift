import XCTest

final class FuelLiftUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppLaunchesSuccessfully() throws {
        let app = XCUIApplication()
        app.launch()
        // App should show either login screen or dashboard
        let exists = app.staticTexts["FuelLift"].waitForExistence(timeout: 5)
            || app.tabBars.firstMatch.waitForExistence(timeout: 5)
        XCTAssertTrue(exists)
    }
}
