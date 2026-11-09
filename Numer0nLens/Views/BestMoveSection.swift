//
//  BestMoveSection.swift
//  Numer0nLens
//

import SwiftUI

/// 最善手（情報量の上位）を出すセクション。履歴が変わるたびにバックグラウンドで計算し直す。
struct BestMoveSection: View {
    let deduction: Deduction
    /// 手をタップしたときに呼ぶ（入力欄に入れるため）。
    let onSelect: (Numer0nNumber) -> Void

    /// 表示する上位の件数。
    static let displayCount = 5

    @State private var result: BestMoveSearch.Result?
    @State private var isComputing = false

    var body: some View {
        Card("最善手") {
            if deduction.candidates.isEmpty {
                Text("候補が無いため、最善手を出せません。")
                    .foregroundStyle(Palette.inkSecondary)
            } else if let result, !isComputing {
                VStack(spacing: 0) {
                    ForEach(Array(result.moves.prefix(Self.displayCount).enumerated()), id: \.element.guess) { rank, move in
                        if rank > 0 {
                            Divider()
                                .overlay(Palette.line)
                        }
                        Button {
                            onSelect(move.guess)
                        } label: {
                            BestMoveRow(rank: rank + 1, move: move)
                                .padding(.vertical, Spacing.small)
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("タップすると入力欄に入ります")
                    }
                }
            } else {
                HStack(spacing: Spacing.small) {
                    ProgressView()
                        .tint(Palette.brand)
                    Text("計算しています…")
                        .foregroundStyle(Palette.inkSecondary)
                }
            }
            Text(footerText)
                .font(.footnote)
                .foregroundStyle(Palette.inkSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        // 履歴が増えたら前の計算をキャンセルして計算し直す（`task(id:)` が前の Task をキャンセルする）。
        .task(id: deduction.history.count) {
            await compute()
        }
    }

    private var footerText: String {
        var text = "情報量（bit）が大きい手ほど、回答で候補を細かく分けられます。タップすると入力欄に入ります。"
        if result?.isApproximate == true, !isComputing {
            text += "\n5 桁は手と候補を抜き出して近似しています。"
        }
        return text
    }

    private func compute() async {
        isComputing = true
        let rule = deduction.rule
        let candidates = deduction.candidates
        do {
            let computed = try await BestMoveSearch.search(rule: rule, candidates: candidates)
            result = computed
            isComputing = false
        } catch {
            // キャンセルされた（次の計算が始まる）ときは何もしない。
        }
    }
}

/// 最善手の 1 行。順位・手（数字タイル）・情報量を並べ、下に絞れる数を添える。
struct BestMoveRow: View {
    let rank: Int
    let move: MoveEvaluation

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.extraSmall) {
            // 5 桁や大きい文字で横に収まらないときは、情報量を次の行に下ろす。
            ViewThatFits(in: .horizontal) {
                HStack(spacing: Spacing.small) {
                    guess
                    Spacer(minLength: Spacing.small)
                    entropy
                }
                VStack(alignment: .leading, spacing: Spacing.extraSmall) {
                    guess
                    entropy
                        .padding(.leading, RankBadge.diameter + Spacing.small)
                }
            }
            VStack(alignment: .leading, spacing: Spacing.extraSmall) {
                if move.isCandidate {
                    Label("当たりの可能性あり", systemImage: "star.fill")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Palette.success)
                }
                let expected = move.expectedRemaining.formatted(.number.precision(.fractionLength(1)))
                Text("最悪 \(move.worstCaseRemaining.formatted()) 通り・平均 \(expected) 通りに絞れる")
                    .font(.caption)
                    .foregroundStyle(Palette.inkSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.leading, RankBadge.diameter + Spacing.small)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }

    private var guess: some View {
        HStack(spacing: Spacing.small) {
            RankBadge(rank: rank)
            DigitTiles(text: move.guess.description, size: .small)
        }
    }

    private var entropy: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text(move.entropy.formatted(.number.precision(.fractionLength(2))))
                .font(Typography.display(size: 20, weight: .semibold, relativeTo: .title3))
                .foregroundStyle(Palette.ink)
            Text("bit")
                .font(.caption)
                .foregroundStyle(Palette.inkSecondary)
        }
    }
}

/// 順位の丸。1 位だけ差し色で塗る。
struct RankBadge: View {
    /// 丸の直径。行の 2 段目を、手のタイルの頭にそろえるのにも使う。
    static let diameter: CGFloat = 26

    let rank: Int

    var body: some View {
        Text("\(rank)")
            .font(Typography.display(size: 15, weight: .bold, relativeTo: .subheadline))
            .foregroundStyle(rank == 1 ? Palette.onBrand : Palette.ink)
            .frame(width: Self.diameter, height: Self.diameter)
            .background(rank == 1 ? Palette.brand : Palette.line, in: Circle())
            .accessibilityLabel("\(rank) 位")
    }
}
