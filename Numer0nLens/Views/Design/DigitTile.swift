//
//  DigitTile.swift
//  Numer0nLens
//

import SwiftUI

/// 数字 1 桁のタイル（ボードゲームの駒・カード風）。下に厚みを付けて、紙の上に置いたように見せる。
struct DigitTile: View {
    /// タイルの大きさ。数字の大きさは Dynamic Type に追従する。
    enum Size {
        case large
        case medium
        case small

        var digitSize: CGFloat {
            switch self {
            case .large: 40
            case .medium: 28
            case .small: 20
            }
        }

        var textStyle: Font.TextStyle {
            switch self {
            case .large: .largeTitle
            case .medium: .title
            case .small: .title3
            }
        }

        var edge: CGFloat {
            switch self {
            case .large: 5
            case .medium: 4
            case .small: 3
            }
        }
    }

    /// 表示する数字。`nil` なら未入力の枠を出す。
    let digit: Character?
    var size: Size = .medium

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: Radius.tile, style: .continuous)
        Text(digit.map { String($0) } ?? " ")
            .font(Typography.display(size: size.digitSize, relativeTo: size.textStyle))
            .foregroundStyle(Palette.ink)
            // 枠の最小の大きさは固定し、文字サイズの設定で数字が最小の枠より大きくなったら、枠は数字に合わせて広がる
            // （枠も倍率で広げると、数字より枠の伸びが大きくなり画面からはみ出すため）。
            .frame(minWidth: size.digitSize * 1.2, minHeight: size.digitSize * 1.5)
            .padding(.horizontal, Spacing.extraSmall)
            .background {
                if digit == nil {
                    shape.strokeBorder(Palette.inkSecondary, style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                } else {
                    // 面と地色の差が小さいので、細い枠で輪郭を出す。
                    shape.fill(Palette.tileFace)
                        .overlay(shape.strokeBorder(Palette.tileEdge, lineWidth: 1))
                        .background(shape.fill(Palette.tileEdge).offset(y: size.edge))
                }
            }
            // 未入力の枠にも厚みの分の余白を付け、入力済みのタイルと高さをそろえる。
            .padding(.bottom, size.edge)
    }
}

/// 数字の並びをタイルで見せる（コール・候補・最善手など）。
struct DigitTiles: View {
    let text: String
    /// 桁数。`text` が短いときは、足りない桁を未入力の枠で埋める。
    var length: Int?
    var size: DigitTile.Size = .medium

    var body: some View {
        HStack(spacing: Spacing.small) {
            ForEach(Array(Self.slots(for: text, length: length).enumerated()), id: \.offset) { _, digit in
                DigitTile(digit: digit, size: size)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Self.accessibilityText(for: text, length: length))
    }

    /// タイルに並べる文字。`length` まで `nil`（未入力）で埋める。`length` より長い分はそのまま出す。
    static func slots(for text: String, length: Int?) -> [Character?] {
        let characters = text.map(Optional.some)
        let missing = max((length ?? 0) - characters.count, 0)
        return characters + Array(repeating: nil, count: missing)
    }

    /// VoiceOver で 1 桁ずつ読ませる（「123」を「百二十三」と読ませない）。
    /// 桁数に足りないときは、画面の点線の枠の代わりに残りの桁数を読む。
    static func accessibilityText(for text: String, length: Int? = nil) -> String {
        let missing = (length ?? 0) - text.count
        if text.isEmpty {
            return missing > 0 ? "未入力、\(missing) 桁" : "未入力"
        }
        let digits = text.map(String.init).joined(separator: " ")
        return missing > 0 ? "\(digits)、残り \(missing) 桁" : digits
    }
}

#Preview {
    VStack(spacing: Spacing.large) {
        DigitTiles(text: "407", size: .large)
        DigitTiles(text: "40", length: 3)
        DigitTiles(text: "52918", size: .small)
    }
    .padding()
    .paperBackground()
}
