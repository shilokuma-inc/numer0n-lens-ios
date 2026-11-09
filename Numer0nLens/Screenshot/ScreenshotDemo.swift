//
//  ScreenshotDemo.swift
//  Numer0nLens
//
//  App Store 用スクリーンショットの撮影モード。
//  Tools/capture_screenshots.sh が次の起動引数でアプリを起動し、目的の画面をデモデータで開かせる。
//
//    -screenshot-demo -screenshot-scene <Scene の rawValue> -AppleLanguages (<言語>) -AppleLocale <ロケール>
//
//  画面を足すときは、Scene に case を足し、Numer0nAnalysisApp.swift の rootView で開く画面を返し、
//  AppStore/screenshots.json の scenes に同じ rawValue を足す（突き合わせは Tools/app_store_config.py が行う）。
//  デモデータはメモリ上にだけ作る（チュートリアルの表示済みなど、保存している値には触らない）。
//

import Foundation

enum ScreenshotDemo {
    /// 撮る画面。rawValue が AppStore/screenshots.json の scene と対応する
    enum Scene: String {
        /// 自分の推理（残り候補・入力欄・最善手）
        case deduction
        /// 相手の推理（上部の進み具合の比較で、自分が優勢なところ）
        case opponent
        /// 残り候補の全件
        case candidates
        /// 桁数を選ぶスタートの画面
        case start
        /// チュートリアルの 1 ページ目
        case tutorial
    }

    /// 撮影モードで起動しているか
    static let isEnabled = ProcessInfo.processInfo.arguments.contains("-screenshot-demo")

    /// 撮影モードで開く画面。撮影モードでないときと、知らない値を渡されたときは nil
    static let scene: Scene? = {
        guard isEnabled else {
            return nil
        }
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-screenshot-scene"), arguments.indices.contains(index + 1) else {
            return nil
        }
        return Scene(rawValue: arguments[index + 1])
    }()

    /// 推理の画面に出すゲーム（3 桁）。自分は 3 回コールして 9 通りまで、相手は 2 回コールして 48 通りまで絞った途中。
    /// App の body が評価し直されても入れ直さないよう、1 回だけ作る。
    static let game: GameState = {
        let game = GameState(digitCount: .three)
        record(game.myDeduction, answer: "407", calls: ["123", "456", "780"])
        record(game.opponentDeduction, answer: "852", calls: ["012", "345"])
        return game
    }()

    /// 残り候補の全件の画面に出す候補（4 桁で 2 回コールして残った 168 通り）
    static let candidates: [Numer0nNumber] = {
        let deduction = Deduction(rule: Rule(digitCount: .four))
        record(deduction, answer: "4071", calls: ["1234", "5678"])
        return deduction.candidates
    }()

    /// `answer` に対する判定を回答として、コールを履歴に入れる。
    private static func record(_ deduction: Deduction, answer: String, calls: [String]) {
        let rule = deduction.rule
        do {
            let answer = try Numer0nNumber(answer, rule: rule)
            for call in calls {
                let guess = try Numer0nNumber(call, rule: rule)
                deduction.addCall(guess: guess, result: judge(guess: guess, answer: answer))
            }
        } catch {
            preconditionFailure("撮影モードのデモデータがルールに合いません: \(error)")
        }
    }
}
