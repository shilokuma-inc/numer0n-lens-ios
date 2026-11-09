//
//  Card.swift
//  Numer0nLens
//

import SwiftUI

/// 紙の上に置いたカード。`List` / `Form` のセクションの代わりに使う。
struct Card<Content: View>: View {
    private let title: String?
    private let content: Content

    init(_ title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            if let title {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Palette.inkSecondary)
                    .accessibilityAddTraits(.isHeader)
            }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.large)
        .foregroundStyle(Palette.ink)
        .background {
            // 影は面にだけ付ける（中身に付けると文字が二重に見える）。
            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .fill(Palette.card)
                .shadow(color: Palette.tileEdge.opacity(0.6), radius: 0, x: 0, y: 3)
        }
        .overlay {
            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .strokeBorder(Palette.line, lineWidth: 1)
        }
    }
}

extension View {
    /// 画面の地色（紙）を敷く。`List` / `Form` の灰色の背景の代わり。
    func paperBackground() -> some View {
        background(Palette.paper.ignoresSafeArea())
    }
}

#Preview {
    ScrollView {
        VStack(spacing: Spacing.large) {
            Card("残り候補") {
                Text("720 通り")
                    .font(Typography.number)
            }
            Card {
                Text("見出しの無いカード")
            }
        }
        .padding()
    }
    .paperBackground()
}
