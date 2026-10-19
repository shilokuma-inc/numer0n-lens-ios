//
//  TutorialView.swift
//  Numer0nLens
//

import SwiftUI

/// アプリの使い方を、横にめくるカードで説明する画面。
struct TutorialView: View {
    /// 「はじめる」か「スキップ」で閉じるときに呼ぶ。
    let onFinish: () -> Void

    private let pages = TutorialPage.all

    @State private var selection: TutorialPage.Kind = TutorialPage.all[0].id

    private var isLastPage: Bool {
        selection == pages.last?.id
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("スキップ", action: onFinish)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Palette.brand)
                    .frame(minHeight: 44)
                    .accessibilityIdentifier("tutorialSkipButton")
                    .opacity(isLastPage ? 0 : 1)
                    .disabled(isLastPage)
                    .accessibilityHidden(isLastPage)
            }
            .padding(.horizontal, Spacing.large)

            TabView(selection: $selection) {
                ForEach(pages) { page in
                    TutorialPageView(page: page)
                        .tag(page.id)
                }
            }
            // 標準の点（灰色の帯）の代わりに、下で差し色のタイルの点を出す。
            .tabViewStyle(.page(indexDisplayMode: .never))

            VStack(spacing: Spacing.large) {
                TutorialPageIndicator(pages: pages.map(\.id), selection: selection)
                Button(isLastPage ? "はじめる" : "次へ", action: next)
                    .buttonStyle(.primary)
                    .accessibilityIdentifier(isLastPage ? "tutorialStartButton" : "tutorialNextButton")
            }
            .padding(Spacing.large)
        }
        .paperBackground()
        // 子のボタンの identifier を上書きしないよう、コンテナとして identifier を付ける。
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tutorial")
        // 「使い方」から全画面で開いたときにも、文字サイズの上限をかける。
        .limitedDynamicTypeSize()
    }

    private func next() {
        guard let index = pages.firstIndex(where: { $0.id == selection }), index + 1 < pages.count else {
            onFinish()
            return
        }
        withAnimation {
            selection = pages[index + 1].id
        }
    }
}

/// いまのページの位置。今のページだけ横に長いタイルにして、色だけに頼らず形でも示す。
struct TutorialPageIndicator: View {
    let pages: [TutorialPage.Kind]
    let selection: TutorialPage.Kind

    var body: some View {
        HStack(spacing: Spacing.small) {
            ForEach(pages, id: \.self) { page in
                Capsule()
                    .fill(page == selection ? Palette.brand : Palette.tileEdge)
                    .frame(width: page == selection ? 24 : 8, height: 8)
            }
        }
        .animation(.snappy, value: selection)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Self.accessibilityText(pages: pages, selection: selection))
    }

    /// VoiceOver の読み上げ（例: 「6 ページ中 2 ページ目」）。
    static func accessibilityText(pages: [TutorialPage.Kind], selection: TutorialPage.Kind) -> String {
        let index = (pages.firstIndex(of: selection) ?? 0) + 1
        return "\(pages.count) ページ中 \(index) ページ目"
    }
}

/// チュートリアルの 1 ページ。文字が大きくてもはみ出さないようスクロールできるようにする。
struct TutorialPageView: View {
    let page: TutorialPage

    /// 文字の大きさの設定に合わせてアイコンも大きくする。
    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 40

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.extraLarge) {
                icon
                Card {
                    Text(page.title)
                        .font(.title3.bold())
                        .foregroundStyle(Palette.ink)
                        .accessibilityAddTraits(.isHeader)
                        .fixedSize(horizontal: false, vertical: true)
                    if page.id == .rule {
                        TutorialRuleExample()
                    }
                    VStack(alignment: .leading, spacing: Spacing.medium) {
                        ForEach(Array(page.paragraphs.enumerated()), id: \.offset) { _, paragraph in
                            Text(paragraph)
                                .foregroundStyle(Palette.ink)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.large)
            .padding(.top, Spacing.large)
            .padding(.bottom, Spacing.extraLarge)
        }
    }

    /// ページのアイコン。数字タイルと同じ面・枠・厚みに載せる。
    private var icon: some View {
        let shape = RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
        return Image(systemName: page.systemImage)
            .font(.system(size: iconSize))
            .foregroundStyle(Palette.brand)
            .frame(width: iconSize * 2, height: iconSize * 2)
            .background {
                shape.fill(Palette.tileFace)
                    .overlay(shape.strokeBorder(Palette.tileEdge, lineWidth: 1))
                    .background(shape.fill(Palette.tileEdge).offset(y: 5))
            }
            .padding(.bottom, 5)
            .accessibilityHidden(true)
    }
}

/// ルールのページの例。相手の数とコールを数字タイルで、回答を EAT / BITE のバッジで見せる。
struct TutorialRuleExample: View {
    /// 見出しの幅。タイルの頭をそろえる。
    @ScaledMetric(relativeTo: .footnote) private var titleWidth: CGFloat = 64

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            row(title: "相手の数", text: TutorialPage.ruleExample.answer)
            row(title: "コール", text: TutorialPage.ruleExample.call)
            EatBiteBadge(result: TutorialPage.ruleExample.result)
                .padding(.leading, titleWidth + Spacing.small)
        }
        .padding(Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.paper, in: RoundedRectangle(cornerRadius: Radius.tile, style: .continuous))
        // 下の本文の「例:」と同じ内容なので、読み上げは 1 つにまとめる。
        .accessibilityElement(children: .combine)
    }

    private func row(title: String, text: String) -> some View {
        HStack(spacing: Spacing.small) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Palette.inkSecondary)
                .frame(minWidth: titleWidth, alignment: .leading)
            DigitTiles(text: text, size: .small)
        }
    }
}

/// チュートリアルを開き直す「？」ボタン。ツールバーに置く。
struct TutorialButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("使い方", systemImage: "questionmark.circle")
        }
        .accessibilityIdentifier("tutorialButton")
    }
}

#Preview {
    TutorialView {}
}
