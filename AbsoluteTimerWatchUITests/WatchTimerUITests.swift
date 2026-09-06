import XCTest

final class WatchTimerUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testStartAndPauseControlsAreUsable() throws {
        let app = XCUIApplication()
        app.launch()

        let pauseButton = app.buttons["Pause"]
        let startButton = app.buttons["Start"]

        if pauseButton.waitForExistence(timeout: 5) {
            pauseButton.tap()
            XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        } else {
            XCTAssertTrue(startButton.waitForExistence(timeout: 5))
            startButton.tap()
            XCTAssertTrue(pauseButton.waitForExistence(timeout: 5))
            pauseButton.tap()
            XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        }
    }
}
