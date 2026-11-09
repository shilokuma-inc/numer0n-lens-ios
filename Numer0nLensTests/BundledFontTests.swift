//
//  BundledFontTests.swift
//  Numer0nLensTests
//

@testable import Numer0nLens
import UIKit
import XCTest

/// 同梱したフォント（El Messiri）が UIAppFonts で登録され、数字を表示できること。
final class BundledFontTests: XCTestCase {
    func testElMessiriIsRegistered() throws {
        XCTAssertTrue(UIFont.familyNames.contains("El Messiri"))
        let font = try XCTUnwrap(UIFont(name: "ElMessiri-Regular", size: 17))
        XCTAssertEqual(font.familyName, "El Messiri")
    }

    func testElMessiriHasAllDigits() throws {
        let font = try XCTUnwrap(UIFont(name: "ElMessiri-Regular", size: 17))
        var characters = Array("0123456789".utf16)
        var glyphs = [CGGlyph](repeating: 0, count: characters.count)
        XCTAssertTrue(CTFontGetGlyphsForCharacters(font as CTFont, &characters, &glyphs, characters.count))
        XCTAssertFalse(glyphs.contains(0))
    }

    func testLicenseIsBundled() throws {
        let url = try XCTUnwrap(Bundle.main.url(forResource: "ElMessiri-OFL", withExtension: "txt"))
        let text = try String(contentsOf: url, encoding: .utf8)
        XCTAssertTrue(text.contains("SIL OPEN FONT LICENSE Version 1.1"))
    }

    /// アプリ内のライセンスの画面に出す全文が、同梱したすべてのフォントについて読み込めること。
    func testEveryFontLicenseTextLoads() throws {
        XCTAssertFalse(FontLicense.all.isEmpty)
        for license in FontLicense.all {
            let text = try XCTUnwrap(license.text(), license.name)
            XCTAssertTrue(text.contains("SIL OPEN FONT LICENSE Version 1.1"), license.name)
            XCTAssertTrue(text.contains("Copyright"), license.name)
        }
        XCTAssertTrue(FontLicense.all.contains { $0.name == "El Messiri" })
    }
}
