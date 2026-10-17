//
//  TutorialUITests.swift
//  Numer0nLensUITests
//

import XCTest

/// 初回起動時のチュートリアルの自動表示を確かめる。
final class TutorialUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// 表示済みの記録を消した状態（初回の起動）で起動する。
    private func launchAsFirstTime(extraArguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-hasSeenTutorial", "NO"] + extraArguments
        app.launch()
        return app
    }

    func testShowsTutorialOnFirstLaunchAndSkipClosesIt() {
        let app = launchAsFirstTime()

        let skipButton = app.buttons["tutorialSkipButton"]
        XCTAssertTrue(skipButton.waitForExistence(timeout: 5))
        skipButton.tap()

        assertTutorialClosed(in: app)
    }

    func testStartButtonOnLastPageClosesTutorial() {
        let app = launchAsFirstTime()

        let nextButton = app.buttons["tutorialNextButton"]
        XCTAssertTrue(nextButton.waitForExistence(timeout: 5))
        // 最後のページまでめくると「はじめる」に変わる。
        let startButton = app.buttons["tutorialStartButton"]
        for _ in 0..<10 where !startButton.exists {
            nextButton.tap()
        }
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        startButton.tap()

        assertTutorialClosed(in: app)
    }

    func testSkipTutorialArgumentSuppressesTutorial() {
        let app = launchAsFirstTime(extraArguments: ["-skipTutorial"])

        XCTAssertTrue(app.buttons["ゲームを始める"].waitForExistence(timeout: 5))
        // 表示のアニメーションが始まる前に判定しないよう、しばらく待っても出ないことを確かめる。
        XCTAssertFalse(app.otherElements["tutorial"].waitForExistence(timeout: 2))
    }

    /// チュートリアルが消えて、スタート画面を操作できること。
    private func assertTutorialClosed(in app: XCUIApplication) {
        let tutorial = app.otherElements["tutorial"]
        let disappeared = expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: tutorial)
        wait(for: [disappeared], timeout: 5)
        // 閉じた後にもう一度出てこないこと。
        XCTAssertFalse(tutorial.waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["ゲームを始める"].isHittable)
    }
}
