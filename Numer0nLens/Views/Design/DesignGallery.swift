//
//  DesignGallery.swift
//  Numer0nLens
//

import SwiftUI

// 見本はリリース版のアプリに入れない（テストは Debug でビルドするので使える）。
#if DEBUG

/// 共通部品の見本（Xcode のプレビューとスクリーンショットで確かめるためのもの。アプリの画面からは出さない）。
struct DesignGallery: View {
    var body: some View {
        ScrollView {
            DesignGalleryContent()
        }
        .paperBackground()
    }
}

/// 見本の中身。スクロールを含まないので、テストで `ImageRenderer` に渡して画像にできる。
struct DesignGalleryContent: View {
    var body: some View {
        VStack(spacing: Spacing.large) {
            Text("Numer0n Lens")
                .font(Typography.largeTitle)
                .foregroundStyle(Palette.ink)
            Card("コール") {
                DigitTiles(text: "407", size: .large)
                EatBiteBadge(result: EatBite(eat: 1, bite: 2))
            }
            Card("入力中") {
                DigitTiles(text: "52", length: 4)
                Button("履歴に追加") {}
                    .buttonStyle(.primary)
                    .disabled(true)
            }
            Card("残り候補") {
                Text("720 通り")
                    .font(Typography.number)
                HStack {
                    Button("使う") {}
                        .buttonStyle(.secondary)
                    Button("取り消す", role: .destructive) {}
                        .buttonStyle(.secondary)
                }
                Button("履歴に追加") {}
                    .buttonStyle(.primary)
            }
        }
        .padding(Spacing.large)
        .paperBackground()
    }
}

#Preview("ライト") {
    DesignGallery()
        .preferredColorScheme(.light)
}

#Preview("ダーク") {
    DesignGallery()
        .preferredColorScheme(.dark)
}

#endif
