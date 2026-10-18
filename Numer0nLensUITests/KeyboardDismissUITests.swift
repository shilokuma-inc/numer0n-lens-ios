//
//  KeyboardDismissUITests.swift
//  Numer0nLensUITests
//

import XCTest

/// 推理画面の数字の入力欄で、テンキーを閉じられることを確かめる。
final class KeyboardDismissUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
        // 先に走る Numer0nLensUITestsLaunchTests が向きを変えたまま終わるため、縦向きに戻す。
        // 横向きだと入力欄が List の画面外になり、要素として見つからない。
        XCUIDevice.shared.orientation = .portrait
    }

    func testDoneButtonDismissesKeyboardInMyDeduction() {
        let app = launchGame()

        assertDoneButtonDismissesKeyboard(in: app)
    }

    func testDoneButtonDismissesKeyboardInOpponentDeduction() {
        let app = launchGame()
        let opponentTab = app.buttons["相手の推理"]
        XCTAssertTrue(opponentTab.waitForExistence(timeout: 5))
        opponentTab.tap()

        assertDoneButtonDismissesKeyboard(in: app)
    }

    /// チュートリアルを出さずに起動し、既定の桁数でゲームを始める。
    private func launchGame() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-skipTutorial"]
        app.launch()
        let startGameButton = app.buttons["ゲームを始める"]
        XCTAssertTrue(startGameButton.waitForExistence(timeout: 5))
        startGameButton.tap()
        return app
    }

    /// 入力欄に桁数より少ない数字を入れ、キーボード上の「完了」で閉じる。
    private func assertDoneButtonDismissesKeyboard(in app: XCUIApplication) {
        let numberField = app.textFields["numberField"]
        XCTAssertTrue(numberField.waitForExistence(timeout: 5))
        numberField.tap()
        numberField.typeText("12")

        // 閉じたことの確認（無いこと）が素通りしないよう、先に開いていることを確かめる。
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        let doneButton = app.buttons["keyboardDoneButton"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 5))
        doneButton.tap()

        let keyboardGone = expectation(for: NSPredicate(format: "count == 0"), evaluatedWith: app.keyboards)
        wait(for: [keyboardGone], timeout: 5)
        // 閉じても入力した値は残る。
        XCTAssertEqual(numberField.value as? String, "12")
    }
}
