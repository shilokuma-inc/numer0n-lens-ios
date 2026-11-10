//
//  AppVersion.swift
//  Numer0nLens
//

import Foundation

/// アプリのバージョンとビルド番号。スタート画面の下に出す。
/// ビルド番号は App Store Connect へのアップロードのときに Xcode が上げるので、手元のビルドでは xcconfig の `CURRENT_PROJECT_VERSION` の値になる。
struct AppVersion: Equatable, Sendable {
    /// バージョン（`CFBundleShortVersionString`。xcconfig の `MARKETING_VERSION`）。
    let version: String
    /// ビルド番号（`CFBundleVersion`）。
    let build: String

    /// アプリ本体のバージョン。Info.plist から読めなければ `nil`。
    static let current = Self(infoDictionary: Bundle.main.infoDictionary)

    /// Info.plist の値から作る。バージョンかビルド番号が無い・空なら `nil`。
    init?(infoDictionary: [String: Any]?) {
        guard let version = Self.value(for: "CFBundleShortVersionString", in: infoDictionary),
              let build = Self.value(for: "CFBundleVersion", in: infoDictionary) else {
            return nil
        }
        self.version = version
        self.build = build
    }

    /// 画面に出す文言（例: 「バージョン 1.1.0（ビルド 12）」）。
    var label: String {
        "バージョン \(version)（ビルド \(build)）"
    }

    private static func value(for key: String, in infoDictionary: [String: Any]?) -> String? {
        guard let value = (infoDictionary?[key] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return nil
        }
        return value
    }
}
