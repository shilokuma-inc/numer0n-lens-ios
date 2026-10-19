//
//  DesignScreenshotTests.swift
//  Numer0nLensTests
//

// 見本（DesignGallery）は Debug ビルドにだけ入るので、このテストも Debug でだけビルドする。
#if DEBUG

@testable import Numer0nLens
import SwiftUI
import XCTest

/// 新デザインの見本と画面をライト / ダークで画像にし、テスト結果（xcresult）に添付する。
/// CI の artifact（TestResults.xcresult）から取り出して、PR で見た目を確かめるために使う（判定はしない）。
@MainActor
final class DesignScreenshotTests: XCTestCase {
    func testDesignGallery() throws {
        for scheme in [ColorScheme.light, .dark] {
            let renderer = ImageRenderer(
                content: DesignGalleryContent()
                    .frame(width: 393)
                    .environment(\.colorScheme, scheme)
            )
            renderer.scale = 2
            let image = try XCTUnwrap(renderer.uiImage, "design-gallery (\(scheme))")
            attach(image, name: "design-gallery-\(scheme == .dark ? "dark" : "light")")
        }
    }

    /// スタートの画面（既定の 3 桁を選んだ状態）。
    func testStartScreen() async throws {
        try await attachScreen(StartView { _ in }, name: "start", height: 852)
    }

    /// 端末の文字サイズを最大（AX5）にしたスタートの画面。アプリの上限（`TextSizeLimit.maximum`）で止まること。
    func testStartScreenWithLargeText() async throws {
        try await attachScreen(
            StartView { _ in }.limitedDynamicTypeSize().environment(\.dynamicTypeSize, .accessibility5),
            name: "start-large-text",
            styles: [.light],
            height: 852
        )
    }

    /// 進み具合の比較の見え方（優勢・当てた・矛盾）。ゲームの画面の上部はこの部品と切り替えで組む。
    func testProgressComparisonStates() throws {
        let comparisons = [
            ProgressComparison(myRemaining: 12, opponentRemaining: 40),
            ProgressComparison(myRemaining: 40, opponentRemaining: 12),
            ProgressComparison(myRemaining: 1, opponentRemaining: 30, iSolved: true),
            ProgressComparison(myRemaining: 0, opponentRemaining: 40)
        ]
        for scheme in [ColorScheme.light, .dark] {
            let renderer = ImageRenderer(
                content: VStack(spacing: Spacing.large) {
                    SideSwitcher(selection: .constant(.mine))
                    ForEach(Array(comparisons.enumerated()), id: \.offset) { _, comparison in
                        ProgressComparisonView(comparison: comparison)
                    }
                }
                .padding(Spacing.large)
                .frame(width: 393)
                .paperBackground()
                .environment(\.colorScheme, scheme)
            )
            renderer.scale = 2
            let image = try XCTUnwrap(renderer.uiImage, "progress-comparison (\(scheme))")
            attach(image, name: "progress-comparison-\(scheme == .dark ? "dark" : "light")")
        }
    }

    /// フォントのライセンスの画面（先頭）。
    func testLicenseScreen() async throws {
        try await attachScreen(LicenseView(), name: "license", height: 852)
    }

    /// 推理の画面（自分の推理・3 桁・履歴 3 件）。
    func testDeductionScreen() async throws {
        let game = try Self.game(digitCount: .three, answer: "407", calls: ["123", "456", "780"])
        try await attachScreen(GameView(game: game) {}, name: "deduction")
    }

    /// 5 桁で履歴の行が折り返すこと、残り候補が多いときの見え方。
    func testDeductionScreenWithFiveDigits() async throws {
        let game = try Self.game(digitCount: .five, answer: "40712", calls: ["12345", "67890"])
        try await attachScreen(GameView(game: game) {}, name: "deduction-five", styles: [.light])
    }

    /// 端末の文字サイズを最大（AX5）にしたときの見え方。アプリの上限（`TextSizeLimit.maximum`）で止まること。
    /// 1 枚の高さには上限があり（約 2,700pt を超えると真っ白になる）、入力欄までを撮る。
    func testDeductionScreenWithLargeText() async throws {
        let game = try Self.game(digitCount: .three, answer: "407", calls: ["123", "456"])
        try await attachScreen(
            GameView(game: game) {}.limitedDynamicTypeSize().environment(\.dynamicTypeSize, .accessibility5),
            name: "deduction-large-text",
            styles: [.light]
        )
    }

    /// 大きい文字での履歴の行。最善手の無い相手の推理で撮り、履歴まで 1 枚に収める。
    func testOpponentDeductionWithLargeText() async throws {
        let game = try Self.game(digitCount: .four, answer: "4071", calls: ["1234", "5678"])
        let deduction = game.myDeduction
        try await attachScreen(
            DeductionView(deduction: deduction, role: .opponent)
                .limitedDynamicTypeSize()
                .environment(\.dynamicTypeSize, .accessibility5),
            name: "deduction-large-text-history",
            styles: [.light]
        )
    }

    /// 最善手のカード（4 桁・最大の文字サイズ）。行が横に収まらないとき、情報量を次の行に下ろすこと。
    func testBestMoveWithLargeText() async throws {
        let game = try Self.game(digitCount: .four, answer: "4071", calls: ["1234"])
        try await attachScreen(
            ScrollView {
                BestMoveSection(deduction: game.myDeduction) { _ in }
                    .padding(Spacing.large)
            }
            .paperBackground()
            .limitedDynamicTypeSize()
            .environment(\.dynamicTypeSize, .accessibility5),
            name: "best-move-large-text",
            styles: [.light],
            height: 1_400
        )
    }

    /// 残り候補の全件の画面（5 桁・30,240 通り）。遅延表示のグリッドで先頭から並ぶこと。
    func testCandidateListScreen() async throws {
        let candidates = Rule(digitCount: .five).allNumbers()
        try await attachScreen(CandidateListView(candidates: candidates), name: "candidate-list", height: 852)
    }

    /// 最大の文字サイズの残り候補のカード（5 桁）。セルの数字が枠からはみ出さないこと。
    func testCandidatePreviewWithLargeText() async throws {
        let candidates = Rule(digitCount: .five).allNumbers()
        try await attachScreen(
            ScrollView {
                CandidatePreviewSection(candidates: candidates)
                    .padding(Spacing.large)
            }
            .paperBackground()
            .limitedDynamicTypeSize()
            .environment(\.dynamicTypeSize, .accessibility5),
            name: "candidate-preview-large-text",
            styles: [.light],
            height: 1_400
        )
    }

    /// 履歴を入れたゲーム。回答は `answer` に対する判定で作る。
    private static func game(digitCount: DigitCount, answer: String, calls: [String]) throws -> GameState {
        let game = GameState(digitCount: digitCount)
        let rule = game.myDeduction.rule
        let answerNumber = try Numer0nNumber(answer, rule: rule)
        for call in calls {
            let guess = try Numer0nNumber(call, rule: rule)
            game.myDeduction.addCall(guess: guess, result: judge(guess: guess, answer: answerNumber))
        }
        return game
    }

    /// 画面を実際のウィンドウに置いて撮る（`ImageRenderer` は TextField・Picker・ScrollView を描けないため）。
    private func attachScreen(
        _ view: some View,
        name: String,
        styles: [UIUserInterfaceStyle] = [.light, .dark],
        height: CGFloat = 2_700
    ) async throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        for style in styles {
            let window = UIWindow(windowScene: scene)
            window.frame = CGRect(x: 0, y: 0, width: 393, height: height)
            window.overrideUserInterfaceStyle = style
            window.rootViewController = UIHostingController(rootView: NavigationStack { view })
            window.isHidden = false
            // レイアウトと最善手の計算を待つ。
            try await Task.sleep(for: .seconds(3))
            let image = UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
                _ = window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
            }
            attach(image, name: "\(name)-\(style == .dark ? "dark" : "light")")
            window.isHidden = true
        }
    }

    private func attach(_ image: UIImage, name: String) {
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

#endif
