//
//  AppVersionTests.swift
//  Numer0nLensTests
//

@testable import Numer0nLens
import XCTest

final class AppVersionTests: XCTestCase {
    func testLabel() throws {
        let appVersion = try XCTUnwrap(AppVersion(infoDictionary: ["CFBundleShortVersionString": "1.1.0", "CFBundleVersion": "12"]))
        XCTAssertEqual(appVersion.version, "1.1.0")
        XCTAssertEqual(appVersion.build, "12")
        XCTAssertEqual(appVersion.label, "バージョン 1.1.0（ビルド 12）")
    }

    /// 前後の空白は落とす。
    func testTrimsWhitespace() throws {
        let appVersion = try XCTUnwrap(AppVersion(infoDictionary: ["CFBundleShortVersionString": " 1.1.0 ", "CFBundleVersion": "12\n"]))
        XCTAssertEqual(appVersion.label, "バージョン 1.1.0（ビルド 12）")
    }

    /// バージョンかビルド番号が無い・空・文字列でないときは作らない（画面にも出さない）。
    func testMissingValues() {
        XCTAssertNil(AppVersion(infoDictionary: nil))
        XCTAssertNil(AppVersion(infoDictionary: [:]))
        XCTAssertNil(AppVersion(infoDictionary: ["CFBundleShortVersionString": "1.1.0"]))
        XCTAssertNil(AppVersion(infoDictionary: ["CFBundleVersion": "12"]))
        XCTAssertNil(AppVersion(infoDictionary: ["CFBundleShortVersionString": "", "CFBundleVersion": "12"]))
        XCTAssertNil(AppVersion(infoDictionary: ["CFBundleShortVersionString": "1.1.0", "CFBundleVersion": "  "]))
        XCTAssertNil(AppVersion(infoDictionary: ["CFBundleShortVersionString": 1.1, "CFBundleVersion": 12]))
    }

    /// アプリ本体の Info.plist から読めること。
    func testCurrentReadsMainBundle() throws {
        let current = try XCTUnwrap(AppVersion.current)
        XCTAssertEqual(current.version, Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)
        XCTAssertEqual(current.build, Bundle.main.infoDictionary?["CFBundleVersion"] as? String)
    }
}
