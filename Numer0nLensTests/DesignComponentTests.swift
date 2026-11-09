//
//  DesignComponentTests.swift
//  Numer0nLensTests
//

@testable import Numer0nLens
import UIKit
import XCTest

/// デザインの土台（Views/Design/）のうち、見た目に依らず確かめられる部分。
final class DesignComponentTests: XCTestCase {
    /// 使う太さがすべて同梱したフォントから取れること（名前を間違えると端末のフォントに黙って置き換わるため）。
    func testEveryTypographyWeightIsAvailable() {
        for weight in Typography.Weight.allCases {
            let font = UIFont(name: weight.rawValue, size: 17)
            XCTAssertNotNil(font, weight.rawValue)
            XCTAssertEqual(font?.familyName, "El Messiri", weight.rawValue)
        }
    }

    func testSlotsFillMissingDigitsWithPlaceholders() {
        XCTAssertEqual(DigitTiles.slots(for: "40", length: 3), ["4", "0", nil])
        XCTAssertEqual(DigitTiles.slots(for: "", length: 3), [nil, nil, nil])
        XCTAssertEqual(DigitTiles.slots(for: "407", length: 3), ["4", "0", "7"])
        XCTAssertEqual(DigitTiles.slots(for: "407", length: nil), ["4", "0", "7"])
        XCTAssertEqual(DigitTiles.slots(for: "4071", length: 3), ["4", "0", "7", "1"])
    }

    func testDigitsAreReadOneByOne() {
        XCTAssertEqual(DigitTiles.accessibilityText(for: "407"), "4 0 7")
        XCTAssertEqual(DigitTiles.accessibilityText(for: ""), "未入力")
        XCTAssertEqual(DigitTiles.accessibilityText(for: "52", length: 4), "5 2、残り 2 桁")
        XCTAssertEqual(DigitTiles.accessibilityText(for: "", length: 4), "未入力、4 桁")
        XCTAssertEqual(DigitTiles.accessibilityText(for: "5291", length: 4), "5 2 9 1")
    }

    func testEatBiteBadgeReadsBothCounts() {
        XCTAssertEqual(EatBiteBadge.accessibilityText(for: EatBite(eat: 1, bite: 2)), "1 EAT、2 BITE")
        XCTAssertEqual(EatBiteBadge.accessibilityText(for: EatBite(eat: 0, bite: 0)), "0 EAT、0 BITE")
    }

    /// EAT と BITE は色だけでなく、形（記号）と文字でも区別する。
    func testEatAndBiteDifferInShapeAndText() {
        let eat = EatBitePill.Kind.eat
        let bite = EatBitePill.Kind.bite
        XCTAssertNotEqual(eat.symbol, bite.symbol)
        XCTAssertNotEqual(eat.title, bite.title)
        XCTAssertNotNil(UIImage(systemName: eat.symbol))
        XCTAssertNotNil(UIImage(systemName: bite.symbol))
    }

    /// アプリの言語が日本語であること。英語のままだと、漢字が中国語の字形で描かれる。
    func testAppLanguageIsJapanese() {
        XCTAssertEqual(Bundle.main.preferredLocalizations.first, "ja")
        XCTAssertEqual(Bundle.main.developmentLocalization, "ja")
    }

    /// 文字サイズの上限が、画面の組み方が崩れるアクセシビリティサイズより手前にあること。
    func testTextSizeLimitStopsBeforeAccessibilitySizes() {
        XCTAssertFalse(TextSizeLimit.maximum.isAccessibilitySize)
    }
}
