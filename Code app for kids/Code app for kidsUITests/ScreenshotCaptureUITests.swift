//
//  ScreenshotCaptureUITests.swift
//  Code app for kidsUITests
//
//  Drives KidSpark Academy through the five App-Store submission screens and
//  attaches a full-device screenshot to the test result at each stop. The
//  attachments are pulled out of the .xcresult bundle by
//  `submission/extract-screenshots.sh`.
//
//  Each step is wrapped so a single failed navigation does not block the
//  remaining shots — we'd rather produce 4 good screens and flag the 5th
//  than abort the whole submission run.
//

import XCTest

final class ScreenshotCaptureUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    @MainActor
    func test_captureSubmissionScreens() throws {
        let app = XCUIApplication()
        app.launch()

        // -----------------------------------------------------------------
        // 0. Age Gate — take the 13+ path. Idempotent if already dismissed.
        // -----------------------------------------------------------------
        let over13 = app.buttons["I'm 13 or older"]
        if over13.waitForExistence(timeout: 4) {
            over13.tap()
        }

        sleep(1)

        // -----------------------------------------------------------------
        // 01 — Home
        // -----------------------------------------------------------------
        attachFullScreenshot(named: "01-home")

        // -----------------------------------------------------------------
        // 02 — Lesson
        //
        // Uses explicit accessibility identifiers ("lang-swift", "lesson-<id>")
        // so we don't rely on fuzzy label matching against translated /
        // combined text.
        // -----------------------------------------------------------------
        let swiftTile = app.buttons["lang-swift"]
        if swiftTile.waitForExistence(timeout: 4) {
            // Scroll it into view first if the challenge card is covering it.
            if !swiftTile.isHittable {
                app.swipeUp()
                usleep(400_000)
            }
            swiftTile.tap()
            sleep(1)

            // Swift basics lesson 0 is id "swift-b1" in the catalog.
            let firstLesson = app.buttons["lesson-swift-b1"]
            if firstLesson.waitForExistence(timeout: 3) {
                firstLesson.tap()
                sleep(1)

                // Advance past the first explainer so a quiz / code step shows.
                let next = app.buttons["Continue"].firstMatch
                if next.waitForExistence(timeout: 2) {
                    next.tap()
                    sleep(1)
                }
            }
        }

        attachFullScreenshot(named: "02-lesson")

        // Return to Home so tab navigation resumes cleanly.
        dismissAnyModals(app: app)
        popToRoot(app: app)

        // -----------------------------------------------------------------
        // 03 — Progress
        // -----------------------------------------------------------------
        tapTab(app: app, label: "Progress")
        sleep(1)
        attachFullScreenshot(named: "03-progress")

        // -----------------------------------------------------------------
        // 04 — Pro / paywall gate
        // -----------------------------------------------------------------
        tapTab(app: app, label: "Pro")
        sleep(1)
        attachFullScreenshot(named: "04-paywall-gate")

        // -----------------------------------------------------------------
        // 05 — Parents (PIN create, first-run)
        // -----------------------------------------------------------------
        tapTab(app: app, label: "Parents")
        sleep(1)
        attachFullScreenshot(named: "05-parents")
    }

    // MARK: - Helpers

    private func tapTab(app: XCUIApplication, label: String) {
        let tabBar = app.tabBars.firstMatch
        let btn = tabBar.buttons[label]
        if btn.exists && btn.isHittable {
            btn.tap()
            return
        }
        let fallback = app.buttons[label].firstMatch
        if fallback.exists && fallback.isHittable {
            fallback.tap()
        }
    }

    private func dismissAnyModals(app: XCUIApplication) {
        let close = app.buttons["Close"].firstMatch
        if close.exists && close.isHittable {
            close.tap()
            return
        }
        // Try swiping down from the top in case a sheet is presented.
        let top = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.05))
        let bottom = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.95))
        top.press(forDuration: 0.1, thenDragTo: bottom)
    }

    private func popToRoot(app: XCUIApplication) {
        // Tap the leading nav bar button up to 3 times to unwind the stack.
        for _ in 0..<3 {
            let back = app.navigationBars.buttons.element(boundBy: 0)
            if back.exists && back.isHittable {
                back.tap()
                usleep(400_000)
            } else {
                break
            }
        }
    }

    private func firstHittableButton(
        in app: XCUIApplication,
        matching predicate: NSPredicate
    ) -> XCUIElement? {
        let matches = app.buttons.matching(predicate)
        for i in 0..<min(matches.count, 8) {
            let el = matches.element(boundBy: i)
            if el.exists && el.isHittable { return el }
        }
        return nil
    }

    private func attachFullScreenshot(named name: String) {
        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
