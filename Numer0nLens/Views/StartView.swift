//
//  StartView.swift
//  Numer0nLens
//

import SwiftUI

/// 桁数を選んでゲームを始める画面。
struct StartView: View {
    let onStart: (DigitCount) -> Void

    @State private var digitCount: DigitCount = .three
    @State private var isShowingTutorial = false

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.extraLarge) {
                hero

                Card("桁数") {
                    DigitCountPicker(selection: $digitCount)
                    Text("0〜9 の数字を重複なしで使います。候補は \(Rule(digitCount: digitCount).numberCount.formatted()) 通りです。")
                        .font(.footnote)
                        .foregroundStyle(Palette.inkSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Button("ゲームを始める") {
                    onStart(digitCount)
                }
                .buttonStyle(.primary)
            }
            .padding(Spacing.large)
        }
        .paperBackground()
        .navigationTitle("ヌメロン解析")
        // 画面の頭に大きく名前を出すので、ナビゲーションバーの題は小さくする。
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                TutorialButton {
                    isShowingTutorial = true
                }
            }
        }
        .tint(Palette.brand)
        .fullScreenCover(isPresented: $isShowingTutorial) {
            TutorialView {
                isShowingTutorial = false
            }
        }
    }

    /// 画面の頭。アプリの名前と、選んだ桁数ぶんの伏せたタイル（当てる数字）を見せる。
    private var hero: some View {
        VStack(spacing: Spacing.medium) {
            DigitTiles(text: String(repeating: "?", count: digitCount.rawValue))
                // 桁数は下の選択肢で読み上げるので、飾りのタイルは読ませない。
                .accessibilityHidden(true)
                .animation(.snappy, value: digitCount)
            VStack(spacing: Spacing.extraSmall) {
                Text("Numer0n Lens")
                    .font(Typography.largeTitle)
                    .foregroundStyle(Palette.ink)
                Text("コールと回答から、相手の数字を絞り込みます。")
                    .font(.subheadline)
                    .foregroundStyle(Palette.inkSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityElement(children: .combine)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.large)
    }
}

/// 桁数の選択肢。数字タイルのように並べ、選んだものを差し色で塗る。
struct DigitCountPicker: View {
    @Binding var selection: DigitCount

    var body: some View {
        HStack(spacing: Spacing.medium) {
            ForEach(DigitCount.allCases, id: \.self) { digitCount in
                option(digitCount)
            }
        }
    }

    private func option(_ digitCount: DigitCount) -> some View {
        let isSelected = digitCount == selection
        let shape = RoundedRectangle(cornerRadius: Radius.tile, style: .continuous)
        return Button {
            selection = digitCount
        } label: {
            VStack(spacing: 0) {
                Text("\(digitCount.rawValue)")
                    .font(Typography.display(size: 32, relativeTo: .title))
                Text("桁")
                    .font(.footnote.weight(.semibold))
            }
            .foregroundStyle(isSelected ? Palette.onBrand : Palette.ink)
            .frame(maxWidth: .infinity, minHeight: 72)
            .padding(.vertical, Spacing.extraSmall)
            .background {
                // 数字タイルと同じく、下に厚みを付ける。選んだものは差し色で塗る。
                shape.fill(isSelected ? Palette.brand : Palette.tileFace)
                    .overlay(shape.strokeBorder(isSelected ? Palette.brand : Palette.tileEdge, lineWidth: 1))
                    .background(shape.fill(Palette.tileEdge).offset(y: 4))
            }
            .padding(.bottom, 4)
            .contentShape(shape)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(digitCount.label)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

extension DigitCount {
    /// 画面に出す名前（例: "3 桁"）。
    var label: String {
        "\(rawValue) 桁"
    }
}

#Preview {
    NavigationStack {
        StartView { _ in }
    }
}
