//
//  ColorTokenTests.swift
//  Numer0nLensTests
//

import UIKit
import XCTest

/// 配色トークン（Asset Catalog の Color Set）がライト / ダークの両方で読め、文字と背景のコントラストが WCAG AA（4.5:1）以上あること。
final class ColorTokenTests: XCTestCase {
    private static let tokens = [
        "Paper", "Card", "TileFace", "TileEdge", "Line",
        "Ink", "InkSecondary", "Brand", "OnBrand",
        "Eat", "Bite", "Success", "Warning", "Danger"
    ]
    private static let backgrounds = ["Paper", "Card", "TileFace"]
    private static let texts = ["Ink", "InkSecondary", "Brand", "Eat", "Bite", "Success", "Warning", "Danger"]
    private static let styles: [UIUserInterfaceStyle] = [.light, .dark]

    func testEveryTokenExistsAndDiffersBetweenLightAndDark() throws {
        for name in Self.tokens {
            let light = try color(name, .light)
            let dark = try color(name, .dark)
            XCTAssertNotEqual(light, dark, name)
        }
    }

    func testTextOnBackgroundsMeetsAA() throws {
        for style in Self.styles {
            for text in Self.texts {
                for background in Self.backgrounds {
                    let ratio = contrast(try color(text, style), try color(background, style))
                    XCTAssertGreaterThanOrEqual(ratio, 4.5, "\(text) on \(background) (\(style.rawValue))")
                }
            }
        }
    }

    func testOnBrandOnFilledBadgesMeetsAA() throws {
        for style in Self.styles {
            for fill in ["Brand", "Eat", "Bite"] {
                let ratio = contrast(try color("OnBrand", style), try color(fill, style))
                XCTAssertGreaterThanOrEqual(ratio, 4.5, "OnBrand on \(fill) (\(style.rawValue))")
            }
        }
    }

    func testEatAndBiteAreDistinguishable() throws {
        for style in Self.styles {
            XCTAssertNotEqual(try color("Eat", style), try color("Bite", style))
        }
    }

    private func color(_ name: String, _ style: UIUserInterfaceStyle) throws -> UIColor {
        let traits = UITraitCollection(userInterfaceStyle: style)
        let color = try XCTUnwrap(UIColor(named: name, in: .main, compatibleWith: traits), name)
        return color.resolvedColor(with: traits)
    }

    private func contrast(_ first: UIColor, _ second: UIColor) -> Double {
        let lighter = max(luminance(first), luminance(second))
        let darker = min(luminance(first), luminance(second))
        return (lighter + 0.05) / (darker + 0.05)
    }

    private func luminance(_ color: UIColor) -> Double {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        // sRGB の外の色空間だと false になり 0 のまま計算されるので、確かめておく。
        XCTAssertTrue(color.getRed(&red, green: &green, blue: &blue, alpha: &alpha))
        func linear(_ value: CGFloat) -> Double {
            let value = Double(value)
            return value <= 0.039_28 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }
        return 0.212_6 * linear(red) + 0.715_2 * linear(green) + 0.072_2 * linear(blue)
    }
}
