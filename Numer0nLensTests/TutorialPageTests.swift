//
//  TutorialPageTests.swift
//  Numer0nLensTests
//

@testable import Numer0nLens
import XCTest

final class TutorialPageTests: XCTestCase {
    func testPageOrder() {
        XCTAssertEqual(TutorialPage.all.map(\.id), [.overview, .rule, .sides, .input, .bestMove, .trouble])
        XCTAssertEqual(TutorialPage.all.map(\.id), TutorialPage.Kind.allCases)
    }

    func testEveryPageHasContent() {
        for page in TutorialPage.all {
            XCTAssertFalse(page.title.isEmpty, "\(page.id)")
            XCTAssertFalse(page.systemImage.isEmpty, "\(page.id)")
            XCTAssertFalse(page.paragraphs.isEmpty, "\(page.id)")
            XCTAssertTrue(page.paragraphs.allSatisfy { !$0.isEmpty }, "\(page.id)")
        }
    }

    /// ルールのページの例（相手の数が 123 で 135 とコール → 1EAT 1BITE）が判定と食い違わないこと。
    func testRuleExampleMatchesJudge() throws {
        let rule = Rule(digitCount: .three)
        let result = judge(guess: try Numer0nNumber("135", rule: rule), answer: try Numer0nNumber("123", rule: rule))
        XCTAssertEqual(result, EatBite(eat: 1, bite: 1))
        let rulePage = try XCTUnwrap(TutorialPage.all.first { $0.id == .rule })
        XCTAssertTrue(rulePage.paragraphs.contains { $0.contains("123") && $0.contains("135") && $0.contains(result.description) })
    }
}
