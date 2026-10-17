//
//  TutorialUITests.swift
//  Numer0nLensUITests
//

import XCTest

/// チュートリアルの初回の自動表示と、「？」からの再表示を確かめる。
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
        // 閉じたことの確認（無いこと）が素通りしないよう、先に見つかることを確かめる。
        XCTAssertTrue(app.otherElements["tutorial"].waitForExistence(timeout: 5))

        let skipButton = app.buttons["tutorialSkipButton"]
        XCTAssertTrue(skipButton.waitForExistence(timeout: 5))
        skipButton.tap()

        assertTutorialClosed(in: app, revealing: app.buttons["ゲームを始める"])
    }

    func testStartButtonOnLastPageClosesTutorial() {
        let app = launchAsFirstTime()
        XCTAssertTrue(app.otherElements["tutorial"].waitForExistence(timeout: 5))

        let nextButton = app.buttons["tutorialNextButton"]
        XCTAssertTrue(nextButton.waitForExistence(timeout: 5))
        // 最後のページまでめくると「はじめる」に変わる。
        let startButton = app.buttons["tutorialStartButton"]
        for _ in 0..<10 where !startButton.exists {
            nextButton.tap()
        }
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        startButton.tap()

        assertTutorialClosed(in: app, revealing: app.buttons["ゲームを始める"])
    }

    func testSkipTutorialArgumentSuppressesTutorial() {
        let app = launchAsFirstTime(extraArguments: ["-skipTutorial"])

        XCTAssertTrue(app.buttons["ゲームを始める"].waitForExistence(timeout: 5))
        // 表示のアニメーションが始まる前に判定しないよう、しばらく待っても出ないことを確かめる。
        XCTAssertFalse(app.otherElements["tutorial"].waitForExistence(timeout: 2))
    }

    func testReopensTutorialFromStartScreen() {
        let app = launchSkippingTutorial()

        openTutorialWithHelpButton(in: app)
        app.buttons["tutorialSkipButton"].tap()

        assertTutorialClosed(in: app, revealing: app.buttons["ゲームを始める"])
    }

    func testReopensTutorialFromGameScreenAndKeepsInput() {
        let app = launchSkippingTutorial()
        let startGameButton = app.buttons["ゲームを始める"]
        XCTAssertTrue(startGameButton.waitForExistence(timeout: 5))
        startGameButton.tap()

        // 入力中の値が、チュートリアルを開いて閉じても残ることを確かめる。
        let numberField = app.textFields.firstMatch
        XCTAssertTrue(numberField.waitForExistence(timeout: 5))
        numberField.tap()
        numberField.typeText("123")

        openTutorialWithHelpButton(in: app)
        app.buttons["tutorialSkipButton"].tap()

        assertTutorialClosed(in: app, revealing: app.buttons["tutorialButton"])
        XCTAssertEqual(numberField.value as? String, "123")
    }

    private func launchSkippingTutorial() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-skipTutorial"]
        app.launch()
        return app
    }

    /// ツールバーの「？」（使い方）からチュートリアルを開く。
    private func openTutorialWithHelpButton(in app: XCUIApplication) {
        let helpButton = app.buttons["tutorialButton"]
        XCTAssertTrue(helpButton.waitForExistence(timeout: 5))
        XCTAssertEqual(helpButton.label, "使い方")
        helpButton.tap()
        XCTAssertTrue(app.otherElements["tutorial"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["tutorialSkipButton"].waitForExistence(timeout: 5))
    }

    /// チュートリアルが消えて、下の画面を操作できること。
    private func assertTutorialClosed(in app: XCUIApplication, revealing element: XCUIElement) {
        let tutorial = app.otherElements["tutorial"]
        let disappeared = expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: tutorial)
        wait(for: [disappeared], timeout: 5)
        // 閉じた後にもう一度出てこないこと。
        XCTAssertFalse(tutorial.waitForExistence(timeout: 2))
        XCTAssertTrue(element.isHittable)
    }
}
