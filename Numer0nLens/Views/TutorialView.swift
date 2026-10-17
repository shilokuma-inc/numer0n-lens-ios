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
                    .accessibilityIdentifier("tutorialSkipButton")
                    .opacity(isLastPage ? 0 : 1)
                    .disabled(isLastPage)
                    .accessibilityHidden(isLastPage)
            }
            .padding(.horizontal)
            .padding(.top, 8)

            TabView(selection: $selection) {
                ForEach(pages) { page in
                    TutorialPageView(page: page)
                        .tag(page.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button(action: next) {
                Text(isLastPage ? "はじめる" : "次へ")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .accessibilityIdentifier(isLastPage ? "tutorialStartButton" : "tutorialNextButton")
            .padding()
        }
        // 子のボタンの identifier を上書きしないよう、コンテナとして identifier を付ける。
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tutorial")
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

/// チュートリアルの 1 ページ。文字が大きくてもはみ出さないようスクロールできるようにする。
struct TutorialPageView: View {
    let page: TutorialPage

    /// 文字の大きさの設定に合わせてアイコンも大きくする。
    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 64

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: page.systemImage)
                    .font(.system(size: iconSize))
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)
                Text(page.title)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(page.paragraphs, id: \.self) { paragraph in
                        Text(paragraph)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            // ページの点と重ならないよう下に余白を取る。
            .padding(.bottom, 56)
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
