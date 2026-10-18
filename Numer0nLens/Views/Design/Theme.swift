//
//  Theme.swift
//  Numer0nLens
//

import SwiftUI

/// 新デザインの色。Asset Catalog の Color Set（ライト / ダーク）を引く。画面からはここを経由して使い、色の値を直接書かない。
enum Palette {
    /// 画面の地色（紙）。
    static let paper = Color(.paper)
    /// カードの面。
    static let card = Color(.card)
    /// 数字タイルの面。
    static let tileFace = Color(.tileFace)
    /// 数字タイルの厚み・影。
    static let tileEdge = Color(.tileEdge)
    /// 枠線・区切り。
    static let line = Color(.line)
    /// 本文の文字。
    static let ink = Color(.ink)
    /// 補足の文字。
    static let inkSecondary = Color(.inkSecondary)
    /// 差し色（アプリアイコンのミント）。
    static let brand = Color(.brand)
    /// 差し色・バッジの塗りの上の文字。
    static let onBrand = Color(.onBrand)
    /// EAT の色。
    static let eat = Color(.eat)
    /// BITE の色。
    static let bite = Color(.bite)
    /// 成功（当たった）。
    static let success = Color(.success)
    /// 注意。
    static let warning = Color(.warning)
    /// エラー・取り消しなどの破壊的な操作。
    static let danger = Color(.danger)
}

/// 数字・英字の見出しに使うフォント。同梱した El Messiri（古代エジプト風）を、文字サイズの設定に追従させて使う。
/// 日本語はこのフォントに無いので、日本語の文章には端末のフォント（`.body` など）を使う。
enum Typography {
    /// フォントの太さ。可変フォントの名前付きインスタンスの PostScript 名。
    enum Weight: String, CaseIterable {
        case regular = "ElMessiri-Regular"
        case medium = "ElMessiri-Medium"
        case semibold = "ElMessiri-SemiBold"
        case bold = "ElMessiri-Bold"
    }

    /// El Messiri のフォント。`textStyle` に合わせて Dynamic Type で大きさが変わる。
    static func display(size: CGFloat, weight: Weight = .bold, relativeTo textStyle: Font.TextStyle) -> Font {
        .custom(weight.rawValue, size: size, relativeTo: textStyle)
    }

    /// 画面の大見出し（英字・数字）。
    static let largeTitle = display(size: 34, relativeTo: .largeTitle)
    /// 見出しの数字（残り候補数など）。
    static let number = display(size: 28, weight: .semibold, relativeTo: .title)
    /// EAT / BITE の表記。
    static let badge = display(size: 17, weight: .semibold, relativeTo: .headline)
}

/// 余白の段階。
enum Spacing {
    static let extraSmall: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let extraLarge: CGFloat = 24
}

/// 角丸の半径。
enum Radius {
    static let card: CGFloat = 18
    static let tile: CGFloat = 12
    static let button: CGFloat = 14
}
