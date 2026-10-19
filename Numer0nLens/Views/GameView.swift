//
//  GameView.swift
//  Numer0nLens
//

import SwiftUI

/// ゲーム中の画面。自分の推理と相手の推理を切り替えて見る。
struct GameView: View {
    let game: GameState
    /// 桁数を選び直すとき（スタート画面に戻るとき）に呼ぶ。
    let onChooseDigitCount: () -> Void

    @State private var side: Side = .mine
    @State private var isConfirmingRestart = false
    @State private var isShowingTutorial = false

    enum Side: Hashable, CaseIterable {
        case mine
        case opponent

        var title: String {
            switch self {
            case .mine: "自分の推理"
            case .opponent: "相手の推理"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: Spacing.medium) {
                SideSwitcher(selection: $side)
                ProgressComparisonView(comparison: ProgressComparison(game: game))
            }
            .padding(.horizontal, Spacing.large)
            .padding(.top, Spacing.small)
            .padding(.bottom, Spacing.medium)
            .background(alignment: .bottom) {
                // 下の推理の画面とスクロールの境目を細い線で示す。
                Palette.line.frame(height: 1)
            }

            switch side {
            case .mine:
                DeductionView(deduction: game.myDeduction, role: .mine)
                    // やり直したら入力欄も空に戻す。
                    .id(ObjectIdentifier(game.myDeduction))
            case .opponent:
                DeductionView(deduction: game.opponentDeduction, role: .opponent)
                    .id(ObjectIdentifier(game.opponentDeduction))
            }
        }
        .navigationTitle("\(game.digitCount.label)のゲーム")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                TutorialButton {
                    isShowingTutorial = true
                }
                Menu {
                    Button("同じ桁数でやり直す", systemImage: "arrow.counterclockwise") {
                        isConfirmingRestart = true
                    }
                    Button("桁数を選び直す", systemImage: "textformat.123") {
                        onChooseDigitCount()
                    }
                } label: {
                    Label("やり直す", systemImage: "arrow.counterclockwise.circle")
                        .labelStyle(.titleAndIcon)
                }
            }
        }
        .tint(Palette.brand)
        .paperBackground()
        .confirmationDialog("履歴を消してやり直しますか？", isPresented: $isConfirmingRestart, titleVisibility: .visible) {
            Button("やり直す", role: .destructive) {
                game.restart()
                side = .mine
            }
        }
        // 開き直して閉じても、ゲームの状態（履歴・入力中の値）はこの画面に残る。
        .fullScreenCover(isPresented: $isShowingTutorial) {
            TutorialView {
                isShowingTutorial = false
            }
        }
    }
}

/// 自分の推理と相手の推理の切り替え。紙の上の溝に、選んだ側をタイルのように置く。
struct SideSwitcher: View {
    @Binding var selection: GameView.Side

    var body: some View {
        HStack(spacing: Spacing.extraSmall) {
            ForEach(GameView.Side.allCases, id: \.self) { side in
                option(side)
            }
        }
        .padding(Spacing.extraSmall)
        .background(Palette.line.opacity(0.5), in: RoundedRectangle(cornerRadius: Radius.button, style: .continuous))
    }

    private func option(_ side: GameView.Side) -> some View {
        let isSelected = side == selection
        let shape = RoundedRectangle(cornerRadius: Radius.button - Spacing.extraSmall, style: .continuous)
        return Button {
            selection = side
        } label: {
            Text(side.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? Palette.ink : Palette.inkSecondary)
                .frame(maxWidth: .infinity, minHeight: 36)
                .padding(.horizontal, Spacing.small)
                .background {
                    if isSelected {
                        shape.fill(Palette.tileFace)
                            .overlay(shape.strokeBorder(Palette.tileEdge, lineWidth: 1))
                            .shadow(color: Palette.tileEdge.opacity(0.8), radius: 0, x: 0, y: 2)
                    }
                }
                .contentShape(shape)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    NavigationStack {
        GameView(game: GameState(digitCount: .four)) {}
    }
}
