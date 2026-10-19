//
//  ProgressComparisonView.swift
//  Numer0nLens
//

import SwiftUI

/// 自分と相手のどちらが先に当てそうかを、残り候補数で並べて見せる。
struct ProgressComparisonView: View {
    let comparison: ProgressComparison

    var body: some View {
        VStack(spacing: Spacing.small) {
            Label(headline, systemImage: headlineSymbol)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(headlineColor)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: Spacing.medium) {
                side(
                    title: "自分 → 相手の数字",
                    remaining: comparison.myRemaining,
                    bits: comparison.myRemainingBits,
                    solved: comparison.iSolved
                )
                Palette.line
                    .frame(width: 1)
                side(
                    title: "相手 → 自分の数字",
                    remaining: comparison.opponentRemaining,
                    bits: comparison.opponentRemainingBits,
                    solved: comparison.opponentSolved
                )
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, Spacing.medium)
        .padding(.vertical, Spacing.small)
        .frame(maxWidth: .infinity)
        .background {
            // 見本のカードと同じ面・枠・厚み。上部は場所が限られるので、余白と角丸だけ小さくする。
            RoundedRectangle(cornerRadius: Radius.tile, style: .continuous)
                .fill(Palette.card)
                .shadow(color: Palette.tileEdge.opacity(0.6), radius: 0, x: 0, y: 2)
        }
        .overlay {
            RoundedRectangle(cornerRadius: Radius.tile, style: .continuous)
                .strokeBorder(Palette.line, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }

    private func side(title: String, remaining: Int, bits: Double, solved: Bool) -> some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Palette.inkSecondary)
            if solved {
                Label("当てた", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .foregroundStyle(Palette.success)
                    .padding(.vertical, Spacing.extraSmall)
            } else {
                HStack(alignment: .firstTextBaseline, spacing: Spacing.extraSmall) {
                    Text("残り")
                        .font(.caption)
                    Text(remaining.formatted())
                        .font(Typography.display(size: 24, weight: .semibold, relativeTo: .title2))
                        .contentTransition(.numericText())
                    Text("通り")
                        .font(.caption)
                }
                .foregroundStyle(Palette.ink)
                // 候補 0 件（入力が矛盾）は情報量を出せないので、1 件（0 bit）と紛れないよう別の文言にする。
                Text(remaining > 0 ? "あと約 \(bits.formatted(.number.precision(.fractionLength(1)))) bit" : "候補なし（入力が矛盾）")
                    .font(.caption2)
                    .foregroundStyle(remaining > 0 ? Palette.inkSecondary : Palette.danger)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var headline: String {
        switch comparison.status {
        case .iSolved: "自分が先に当てました"
        case .opponentSolved: "相手が先に当てました"
        case .bothSolved: "どちらも当てました"
        case .undetermined: "候補が 0 通りの推理があり、比べられません"
        case .inProgress(.me): "自分のほうが当てるのに近い"
        case .inProgress(.opponent): "相手のほうが当てるのに近い"
        case .inProgress(.even): "互角"
        }
    }

    /// 色だけに頼らず、記号でもどちらが優勢かを示す。
    private var headlineSymbol: String {
        switch comparison.status {
        case .iSolved, .bothSolved: "checkmark.seal.fill"
        case .opponentSolved: "flag.fill"
        case .undetermined: "exclamationmark.triangle.fill"
        case .inProgress(.me): "arrow.up.right.circle.fill"
        case .inProgress(.opponent): "arrow.down.right.circle.fill"
        case .inProgress(.even): "equal.circle.fill"
        }
    }

    private var headlineColor: Color {
        switch comparison.status {
        case .iSolved, .inProgress(.me): Palette.success
        case .opponentSolved, .inProgress(.opponent): Palette.warning
        case .undetermined: Palette.danger
        case .bothSolved, .inProgress(.even): Palette.ink
        }
    }
}

#Preview {
    VStack(spacing: Spacing.large) {
        ProgressComparisonView(comparison: ProgressComparison(myRemaining: 12, opponentRemaining: 40))
        ProgressComparisonView(comparison: ProgressComparison(myRemaining: 1, opponentRemaining: 0, iSolved: true))
        ProgressComparisonView(comparison: ProgressComparison(myRemaining: 0, opponentRemaining: 40))
    }
    .padding()
    .paperBackground()
}
