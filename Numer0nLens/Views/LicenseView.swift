//
//  LicenseView.swift
//  Numer0nLens
//

import SwiftUI

/// 同梱したフォントのライセンス。SIL Open Font License は、フォントと一緒に著作権表示とライセンスの全文を配ることを求める。
struct FontLicense: Identifiable, Hashable {
    /// フォントの名前。
    let name: String
    /// ライセンスの名前。
    let licenseName: String
    /// ライセンスの全文を置いたファイル（拡張子 txt、アプリのバンドルに入れる）。
    let resource: String

    var id: String { resource }

    /// アプリに同梱しているフォント。
    static let all: [Self] = [
        Self(name: "El Messiri", licenseName: "SIL Open Font License 1.1", resource: "ElMessiri-OFL")
    ]

    /// ライセンスの全文。ファイルが見つからなければ `nil`。
    func text(in bundle: Bundle = .main) -> String? {
        guard let url = bundle.url(forResource: resource, withExtension: "txt") else {
            return nil
        }
        return try? String(contentsOf: url, encoding: .utf8)
    }
}

/// 同梱したフォントのライセンスの一覧。
struct LicenseView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.large) {
                Text("このアプリの数字と英字には、次のフォントを使っています。")
                    .font(.footnote)
                    .foregroundStyle(Palette.inkSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                ForEach(FontLicense.all) { license in
                    LicenseCard(license: license)
                }
            }
            .padding(Spacing.large)
        }
        .paperBackground()
        .navigationTitle("ライセンス")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// フォント 1 つ分のライセンス。名前を El Messiri で見せ、全文をそのまま載せる。
struct LicenseCard: View {
    let license: FontLicense

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: Spacing.extraSmall) {
                Text(license.name)
                    .font(Typography.display(size: 24, relativeTo: .title2))
                    .foregroundStyle(Palette.ink)
                    .accessibilityAddTraits(.isHeader)
                Text(license.licenseName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Palette.inkSecondary)
            }
            Divider()
                .overlay(Palette.line)
            if let text = license.text() {
                // 原文は英語なので、改行も含めてそのまま出す。
                Text(verbatim: text)
                    .font(.caption.monospaced())
                    .foregroundStyle(Palette.ink)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("ライセンスの文を読み込めませんでした。")
                    .font(.footnote)
                    .foregroundStyle(Palette.danger)
            }
        }
    }
}

/// スタートの画面の下に置く、ライセンスの画面へのリンク。
struct LicenseLink: View {
    var body: some View {
        NavigationLink {
            LicenseView()
        } label: {
            Label("フォントのライセンス", systemImage: "doc.text")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Palette.brand)
                .frame(minHeight: 44)
                .contentShape(Rectangle())
        }
    }
}

#Preview {
    NavigationStack {
        LicenseView()
    }
}
