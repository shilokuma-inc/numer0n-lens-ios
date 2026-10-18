//
//  EatBiteBadge.swift
//  Numer0nLens
//

import SwiftUI

/// EAT / BITE の数のバッジ。色だけに頼らず、形（EAT は丸・BITE はひし形）と文字でも区別する。
struct EatBiteBadge: View {
    let result: EatBite

    var body: some View {
        HStack(spacing: Spacing.small) {
            EatBitePill(kind: .eat, count: result.eat)
            EatBitePill(kind: .bite, count: result.bite)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Self.accessibilityText(for: result))
    }

    /// VoiceOver の読み上げ（例: 「1 EAT、2 BITE」）。
    static func accessibilityText(for result: EatBite) -> String {
        "\(result.eat) EAT、\(result.bite) BITE"
    }
}

/// EAT か BITE の片方。
struct EatBitePill: View {
    enum Kind {
        case eat
        case bite

        var title: String {
            switch self {
            case .eat: "EAT"
            case .bite: "BITE"
            }
        }

        /// 色に頼らず区別するための形。
        var symbol: String {
            switch self {
            case .eat: "circle.fill"
            case .bite: "diamond.fill"
            }
        }

        var color: Color {
            switch self {
            case .eat: Palette.eat
            case .bite: Palette.bite
            }
        }
    }

    let kind: Kind
    let count: Int

    var body: some View {
        HStack(spacing: Spacing.extraSmall) {
            Image(systemName: kind.symbol)
                .imageScale(.small)
            Text("\(count)")
                .monospacedDigit()
            Text(kind.title)
        }
        .font(Typography.badge)
        .foregroundStyle(Palette.onBrand)
        .padding(.horizontal, Spacing.medium)
        .padding(.vertical, Spacing.extraSmall)
        .background(kind.color, in: Capsule())
    }
}

#Preview {
    VStack(spacing: Spacing.large) {
        EatBiteBadge(result: EatBite(eat: 1, bite: 2))
        EatBiteBadge(result: EatBite(eat: 3, bite: 0))
    }
    .padding()
    .paperBackground()
}
