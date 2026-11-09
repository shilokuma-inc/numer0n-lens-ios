//
//  ButtonStyles.swift
//  Numer0nLens
//

import SwiftUI

/// 主ボタン（「履歴に追加」「始める」など）。差し色で塗る。
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(.horizontal, Spacing.large)
            .foregroundStyle(isEnabled ? Palette.onBrand : Palette.inkSecondary)
            .background(
                isEnabled ? Palette.brand : Palette.line,
                in: RoundedRectangle(cornerRadius: Radius.button, style: .continuous)
            )
            .opacity(configuration.isPressed ? 0.8 : 1)
            .offset(y: configuration.isPressed ? 1 : 0)
    }
}

/// 副ボタン（「取り消す」「使う」など）。枠だけを描く。`role: .destructive` のボタンはエラーの色にする。
struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let color = configuration.role == .destructive ? Palette.danger : Palette.brand
        configuration.label
            .font(.subheadline.weight(.semibold))
            .frame(minHeight: 44)
            .padding(.horizontal, Spacing.large)
            .foregroundStyle(isEnabled ? color : Palette.inkSecondary)
            .overlay {
                RoundedRectangle(cornerRadius: Radius.button, style: .continuous)
                    .strokeBorder(isEnabled ? color : Palette.line, lineWidth: 1.5)
            }
            .contentShape(RoundedRectangle(cornerRadius: Radius.button, style: .continuous))
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}

#Preview {
    VStack(spacing: Spacing.large) {
        Button("履歴に追加") {}
            .buttonStyle(.primary)
        Button("履歴に追加") {}
            .buttonStyle(.primary)
            .disabled(true)
        HStack {
            Button("使う") {}
                .buttonStyle(.secondary)
            Button("最後の履歴を取り消す", role: .destructive) {}
                .buttonStyle(.secondary)
        }
    }
    .padding()
    .paperBackground()
}
