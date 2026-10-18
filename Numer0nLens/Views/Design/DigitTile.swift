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

    @ScaledMetric private var scale: CGFloat = 1

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: Radius.tile, style: .continuous)
        Text(digit.map { String($0) } ?? " ")
            .font(Typography.display(size: size.digitSize, relativeTo: size.textStyle))
            .foregroundStyle(Palette.ink)
            .frame(minWidth: size.digitSize * 1.2 * scale, minHeight: size.digitSize * 1.5 * scale)
            .padding(.horizontal, Spacing.extraSmall)
            .background {
                if digit == nil {
                    shape.strokeBorder(Palette.inkSecondary, style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                } else {
                    shape.fill(Palette.tileFace)
                        .background(shape.fill(Palette.tileEdge).offset(y: size.edge))
                }
            }
            .padding(.bottom, digit == nil ? 0 : size.edge)
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
        .accessibilityLabel(Self.accessibilityText(for: text))
    }

    /// タイルに並べる文字。`length` まで `nil`（未入力）で埋める。`length` より長い分はそのまま出す。
    static func slots(for text: String, length: Int?) -> [Character?] {
        let characters = text.map(Optional.some)
        let missing = max((length ?? 0) - characters.count, 0)
        return characters + Array(repeating: nil, count: missing)
    }

    /// VoiceOver で 1 桁ずつ読ませる（「123」を「百二十三」と読ませない）。
    static func accessibilityText(for text: String) -> String {
        text.isEmpty ? "未入力" : text.map(String.init).joined(separator: " ")
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
