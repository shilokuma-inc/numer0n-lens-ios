//
//  PrivacyManifestTests.swift
//  Numer0nLensTests
//

import Foundation
import XCTest

/// プライバシーマニフェストがアプリに同梱され、App Store Connect の「App のプライバシー」（データの収集なし）と合っていること。
final class PrivacyManifestTests: XCTestCase {
    func testDeclaresNoTrackingAndNoCollectedData() throws {
        let manifest = try loadManifest()
        XCTAssertEqual(manifest["NSPrivacyTracking"] as? Bool, false)
        XCTAssertEqual((manifest["NSPrivacyTrackingDomains"] as? [String])?.isEmpty, true)
        XCTAssertEqual((manifest["NSPrivacyCollectedDataTypes"] as? [Any])?.isEmpty, true)
    }

    /// チュートリアルの表示済みの記録を @AppStorage（UserDefaults）に保存しているので、その理由を申告していること。
    func testDeclaresUserDefaultsReason() throws {
        let types = try XCTUnwrap(loadManifest()["NSPrivacyAccessedAPITypes"] as? [[String: Any]])
        let userDefaults = try XCTUnwrap(
            types.first { $0["NSPrivacyAccessedAPIType"] as? String == "NSPrivacyAccessedAPICategoryUserDefaults" }
        )
        XCTAssertEqual(userDefaults["NSPrivacyAccessedAPITypeReasons"] as? [String], ["CA92.1"])
    }

    private func loadManifest() throws -> [String: Any] {
        let url = try XCTUnwrap(Bundle.main.url(forResource: "PrivacyInfo", withExtension: "xcprivacy"))
        let data = try Data(contentsOf: url)
        return try XCTUnwrap(PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any])
    }
}
