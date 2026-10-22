# リポジトリ名
numer0n-lens-ios

## 概要
ヌメロン解析アプリ
選択と相手の回答から可能性のパターンを提示する
最善手を提示する機能も作成予定

## 使用技術
- SwiftUI（`@main` の `App` から起動。Storyboard は使わない）
- Observation（`@Observable` で状態を管理）
- XCTest（判定・候補の絞り込み・最善手のロジックを単体テスト）
- 最低 iOS 17.0。アプリは外部ライブラリ・サーバーを使わない（オフラインで完結。SwiftLint はビルド時だけ使う）

## Environment

- Xcode 26.6（CI で固定）
- iOS 17.0 以上
- SwiftUI（Observation）/ XCTest
- SwiftLint 0.65.1（Build Tool Plugin。バイナリだけを配布する [SwiftLintPlugins](https://github.com/SimplyDanny/SwiftLintPlugins) 経由）

## Status

<div style="margin:0px;padding:0px;">
  <table width="98%" style="border-collapse: collapse;border:2px double #000080;text-align:center;margin:auto;">
    <tbody>
      <tr>
        <td style="border:2px double #000080;">branch \ workflow</td>
        <td style="border:2px double #000080;">Build</td>
        <td style="border:2px double #000080;">Archive</td>
        <td style="border:2px double #000080;">Upload</td>
      </tr>
      <tr>
        <td style="border:2px double #000080;text-align:left;">main</td>
        <td style="border:2px double #000080;text-align:center;">
          <a href="https://github.com/shilokuma-inc/numer0n-lens-ios/actions/workflows/build.yml?query=branch%3Amain">
            <img src="https://github.com/shilokuma-inc/numer0n-lens-ios/actions/workflows/build.yml/badge.svg?branch=main" alt="Build">
          </a>
        </td>
        <td style="border:2px double #000080;text-align:center;">
          <a href="https://github.com/shilokuma-inc/numer0n-lens-ios/actions/workflows/archive.yml?query=branch%3Amain">
            <img src="https://github.com/shilokuma-inc/numer0n-lens-ios/actions/workflows/archive.yml/badge.svg?branch=main" alt="Archive">
          </a>
        </td>
        <td style="border:2px double #000080;text-align:center;">
        </td>
      </tr>
      <tr>
        <td style="border:2px double #000080;text-align:left;">develop</td>
        <td style="border:2px double #000080;text-align:center;">
          <a href="https://github.com/shilokuma-inc/numer0n-lens-ios/actions/workflows/build.yml?query=branch%3Adevelop">
            <img src="https://github.com/shilokuma-inc/numer0n-lens-ios/actions/workflows/build.yml/badge.svg?branch=develop" alt="Build">
          </a>
        </td>
        <td style="border:2px double #000080;text-align:center;">
        </td>
        <td style="border:2px double #000080;text-align:center;">
          <a href="https://github.com/shilokuma-inc/numer0n-lens-ios/actions/workflows/upload.yml?query=branch%3Adevelop">
            <img src="https://github.com/shilokuma-inc/numer0n-lens-ios/actions/workflows/upload.yml/badge.svg?branch=develop" alt="Upload">
          </a>
        </td>
      </tr>
    </tbody>
  </table>
</div>

## ビルド

```bash
xcodebuild -project Numer0nLens.xcodeproj -scheme Numer0nLens -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
xcodebuild test -project Numer0nLens.xcodeproj -scheme Numer0nLens -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:Numer0nLensTests -parallel-testing-enabled NO
```

- SwiftLint は Build Tool Plugin として全ターゲットに適用されます。コマンドラインで初めてビルドするときは、Xcode でプラグインを信頼する（Trust & Enable）か、`-skipPackagePluginValidation` を付けてください
- CI と同じ検証は、SPM が解決した SwiftLint で `swiftlint lint --strict` を実行します（ルールは [.swiftlint.yml](.swiftlint.yml)）

## 署名情報とバージョン

署名情報・Bundle ID・バージョンは pbxproj ではなく [Configs/Project.xcconfig](Configs/Project.xcconfig) に集約しています。

| 設定 | 内容 |
|---|---|
| `DEVELOPMENT_TEAM` | Apple Developer Program の Team ID（`XU74X3434S`） |
| `APP_BUNDLE_IDENTIFIER` | アプリ本体の Bundle Identifier（`jp.shilokuma.Numer0nLens`）。テストターゲットは `.Tests` / `.UITests` を付けて派生します |
| `APP_DISPLAY_NAME` | ホーム画面に表示するアプリ名（`Numer0n Lens`） |
| `APP_MODULE_NAME` | アプリ本体の Swift モジュール名（`Numer0nLens`）。テストは `@testable import Numer0nLens` で読み込みます |
| `MARKETING_VERSION` | アプリのバージョン。ビルド番号（`CURRENT_PROJECT_VERSION`）は Upload のときに App Store Connect の最新ビルドを見て Xcode が自動で増やすため、手で上げる必要はありません |
| `IPHONEOS_DEPLOYMENT_TARGET` | 最低サポート OS（17.0） |

## CI（GitHub Actions）

ワークフローは [shilokuma-inc/template-app-ios](https://github.com/shilokuma-inc/template-app-ios) のものを移植しています。

| ブランチ | Build（ビルド + テスト + SwiftLint） | Archive（IPA Export） | Upload（App Store Connect） |
|---|:-:|:-:|:-:|
| `main` | ✅ | ✅ | |
| `develop` | ✅ | | ✅ |
| `release/**` | ✅ | | ✅ |
| その他の作業ブランチ | ✅（Unit テストのみ） | | |
| Pull Request の作成時（opened / reopened / ready_for_review） | ✅ | | |
| Fork からの Pull Request | ✅ | | |

- Upload は Archive → IPA Export を含むため、`develop` / `release/**` では Archive を別途実行しません
- Archive / Upload は Actions タブから手動でも実行できます（Run workflow）
- `epic/**` 宛ての Pull Request（ralph-loop の子 PR）では PR イベントで Build を実行しません（ブランチへの push で実行されます）
- ドキュメントだけの変更（`**/*.md`、`docs/**`）では Build を実行しません
- Xcode のバージョンは [.github/workflows/_build.yml](.github/workflows/_build.yml) と [.github/workflows/_archive.yml](.github/workflows/_archive.yml) の `xcode-version` で固定しています
- CI のワークフローは、リポジトリ直下の `*.xcodeproj` と同名の共有スキーム（`Numer0nLens`）があることを前提にしています

### Archive / Upload を動かすために必要な設定

Archive / Upload は App Store Connect API Key で認証します。以下はリポジトリの外での設定で、人が行います。

1. **リポジトリ変数 `ENABLE_DELIVERY`**（Settings → Secrets and variables → Actions → Variables）:
   App Store Connect にアプリを作るまでは `ENABLE_DELIVERY=false` を設定して Upload を止めます（`develop` への push で Upload が走るため）。アプリを作ったら変数を消すか `true` にします
2. **Secrets**（org で共有しているものを使います。このリポジトリから使えることを確認してください）:

   | Secret | 内容 |
   |---|---|
   | `EXPORT_OPTIONS` | `ExportOptions.plist` の内容。[docs/ExportOptions.sample.plist](docs/ExportOptions.sample.plist) の `teamID` を `DEVELOPMENT_TEAM` と同じ値にしたもの |
   | `APPLE_API_KEY_BASE64` | App Store Connect の API Key（`.p8`）を base64 エンコードした文字列 |
   | `APPLE_API_KEY_ID` | API Key の Key ID |
   | `APPLE_API_ISSUER_ID` | API Key の Issuer ID |

3. **App Store Connect のアプリ**: Bundle ID `jp.shilokuma.Numer0nLens` のアプリを Web 画面で作成します（API では作れません）。
   アプリが無いまま Upload が走ると、[.github/scripts/check-app-store-app.rb](.github/scripts/check-app-store-app.rb) が「新規アプリ」画面に入力する値を Job Summary に出して止まります

## App Store の掲載情報（スクリーンショット・説明文・App 情報・ヘッダー）

App Store のプロダクトページに載せるものは、`AppStore/` の JSON を元ネタにして、手動実行のワークフローで App Store Connect に反映します（[template-app-ios](https://github.com/shilokuma-inc/template-app-ios) から移植）。
反映先は「編集できる状態のバージョン」だけで、審査中・配信済みのバージョンには触りません。
どのワークフローも、リポジトリ変数 `ENABLE_DELIVERY=false` のときは反映しません。

| ワークフロー | 反映するもの | 元ネタ | ランナー |
|---|---|---|---|
| `Screenshots/App Store` | スクリーンショット（iPhone 6.9 inch / 6.3 inch / iPad 13 inch / iPhone Duo） | `AppStore/screenshots.json` / `AppStore/languages.json` / `AppStore/app.json` | 撮影だけ macOS、縮小と反映は ubuntu |
| `Metadata/App Store` | 名前・サブタイトル・説明文・キーワード・プロモーションテキスト・最新情報・URL・プライバシーポリシーの URL・著作権と、App 情報（カテゴリ・コンテンツの権利・年齢制限）・審査のメモ・価格と配信状況（既定は dry-run） | `AppStore/metadata/*.json` / `AppStore/app_info.json` / `AppStore/review_notes.txt` | ubuntu |
| `Creative assets/App Store` | プロダクトページのヘッダーと検索結果のクリエイティブアセット（既定は dry-run） | `AppStore/creative_assets.json` / `AppStore/creative/<言語>/` | ubuntu |
| `Verify/App Store metadata` | PR で、文字数の上限・App 情報の書き方・撮影設定・撮影モードの Scene との対応を検査する | `AppStore/**` | ubuntu |

- 言語は日本語だけです（アプリの文言が日本語だけのため。[AppStore/languages.json](AppStore/languages.json)）
- リリースのときは、`release/x.y.z` を切ってから、そのブランチを選んで `Screenshots/App Store` → `Metadata/App Store`（dry-run で差分を見てから本番）の順に流します

**スクリーンショット**

- 撮影はアプリの撮影モード（[Numer0nLens/Screenshot/ScreenshotDemo.swift](Numer0nLens/Screenshot/ScreenshotDemo.swift)）で行います。`Tools/capture_screenshots.sh` が `-screenshot-demo -screenshot-scene <名前>` と言語を起動引数で渡し、アプリはデモデータ（3 桁のゲームの途中など）で目的の画面を開きます
- 撮る画面: 自分の推理 → 相手の推理 → 残り候補の全件 → スタート → チュートリアル（[AppStore/screenshots.json](AppStore/screenshots.json) の `scenes` の順）
- 画面を足すときは、`ScreenshotDemo.Scene` に case を足し、`Numer0nAnalysisApp.swift` の `rootView` で開く画面を返し、`AppStore/screenshots.json` の `scenes` に同じ名前を足します（1 表示サイズにつき 10 枚まで）
- 撮るのはリリースのときだけです。`release/**` ブランチを選んで手動実行します（それ以外のブランチでは止まります）
- macOS ランナーの枠を開発のビルドと取り合わないよう、撮影は 1 本ずつ流します。6.3 inch（`deriveFrom`）は撮らずに 6.9 inch を ubuntu で縮めて作り、App Store Connect への反映も ubuntu で行います
- iPhone Duo は Xcode 27.1 と iOS 27.1 のランタイムが要るので、`xcode-27` のランナーで撮ります（`screenshots.json` の `runsOn` / `xcodeVersion`）
- 手元で撮るなら `SKIP_PACKAGE_PLUGIN_VALIDATION=1 Tools/capture_screenshots.sh APP_IPHONE_67 ja`（出力は `build/screenshots/`）

**名前・説明文・最新情報**

- `AppStore/metadata/ja.json` と `shared.json` に書きます。仮の文言（`TODO:`）が残っているあいだは反映できません
- 名前（`name`）・サブタイトル（`subtitle`）も `ja.json` に書きます（どちらも 30 字まで）。App Store Connect では「App 情報」の項目に書き込みます
- `shared.json` の `privacyPolicyUrl`（プライバシーポリシーの URL。必須）は App 情報に、`copyright`（著作権。必須）はバージョンに書き込みます。プライバシーポリシーは [shilokuma-inc/shilokuma-web](https://github.com/shilokuma-inc/shilokuma-web) の `privacy/apps.json`（slug は `numer0n-lens`）から作られます
- 「このバージョンの最新情報」は `whatsNew` に `{"version": "1.1.0", "text": "…"}` の形で書きます。`version` が反映先のバージョンと一致するときだけ書き込むので、リリースごとに両方を書き換えます（最初のバージョンには最新情報の欄がありません）

**プロダクトページのヘッダーと検索結果**（[App Store asset best practices](https://developer.apple.com/app-store/asset-best-practices/)）

- iOS 27 / iPadOS 27 以降の App Store では、スクリーンショットとは別に、プロダクトページのヘッダー（21:9、3840x1646）と検索結果（3:2、3840x2560）に画像を載せられます
- 元は [AppStore/creative/src/creative.html](AppStore/creative/src/creative.html)。色と文言（`TODO:`）をアプリに合わせて書き換え、6.9 inch のスクリーンショットを撮ってから `Tools/render_creative_assets.sh build/screenshots/APP_IPHONE_67 "Numer0n Lens"` で書き出し（Google Chrome を使います）、画像もコミットします
- `Creative assets/App Store` を `ref-data` → `dry-run` → `upload` の順に流して反映します
- 反映したら、App Store Connect のプレビューで iPhone / iPad の見え方を確かめてから審査に出します

**App 情報・審査の情報・価格と配信状況**

- `AppStore/app_info.json` に書き、`Metadata/App Store` が説明文の後に続けて反映します（`Tools/upload_app_info.py`）

| 項目 | JSON のキー | 書き込み方 |
|---|---|---|
| カテゴリ | `primaryCategory`（必須）・`secondaryCategory`・`primarySubcategories` / `secondarySubcategories` | カテゴリの ID（`GAMES`・サブカテゴリの `GAMES_PUZZLE` など）で書きます。ID が違えば、使える一覧を出して書き込む前に止まります。カテゴリを変えたときは、書いていない古いサブカテゴリを App Store Connect からも外します |
| コンテンツの権利 | `contentRightsDeclaration` | 第三者のコンテンツを使わないなら `DOES_NOT_USE_THIRD_PARTY_CONTENT` |
| 年齢制限 | `ageRating` | 質問ごとの回答。広告・ユーザーの投稿・課金・Web の閲覧が無いので、すべて「なし」（4+）です。機能を足したら見直します |
| App Review に関する情報 | `review`（`demoAccountRequired`・`notesFile`） | メモは `notesFile` の [AppStore/review_notes.txt](AppStore/review_notes.txt) を書き込みます。連絡先は JSON に書かず、Organization の Secrets（`APP_REVIEW_CONTACT_*`）から渡します。値はログに出しません |
| 価格 | `pricing` | **App Store Connect で未設定のときだけ**無料にします。設定済みなら触りません |
| 配信状況 | `availability` | **App Store Connect で未設定のときだけ**書き込みます。設定済みなら触りません |

- 価格と配信状況は 1.0.0 の提出の時点で設定済みなので、このリポジトリからは変わりません。変えるときは App Store Connect の「価格および配信状況」で行います
- 連絡先の Secrets が登録されていなければ連絡先は書き込まず、Job Summary の「審査に出す前に App Store Connect で入力が要るもの」に出ます

**App Review に関する情報（審査メモ・画面収録）**

1.0.0 の最初の審査で、Guideline 2.1 - Information Needed（実機の画面収録と、目的・使い方・外部サービス・地域差・第三者の素材についての説明）を求められました。
次の審査でも同じことを聞かれないよう、提出の前に App Store Connect の「App Review に関する情報」に入れておきます。

- **メモ**: [AppStore/review_notes.txt](AppStore/review_notes.txt) を `Metadata/App Store` で反映します（英語・上限 4000 字。前後の空行は落とします）。画面の文言や機能を変えたら、このファイルも直します
- **添付ファイル**: 実機の画面収録は API で反映しないので、App Store Connect で添付します。審査から質問が来たときは、App Review からのメッセージへの返信にも同じ動画とメモを付けます
- **画面収録の撮り方**
  - 実機（最新の iOS）に、審査に出すビルドを TestFlight で入れます。チュートリアルも映すため、一度アプリを削除してから入れ直し、初回起動の状態にします
  - 撮影中に通知が映らないよう、集中モードをオンにします。コントロールセンターの「画面収録」で撮り始め、ホーム画面のアイコンをタップしてアプリを起動するところから撮ります
  - 映す流れ（1〜3 分）: チュートリアルを数ページ見て閉じる → 3 桁でゲームを始める → 「自分の推理」でコールと EAT / BITE を 2〜3 件入れ、残り候補と最善手が変わるのを見せる → 最善手をタップして入力欄に入れる → 「すべて見る」で候補の一覧と先頭の数字での絞り込み → 「相手の推理」に切り替えて 1〜2 件入れる → 矛盾する入力を入れて警告を出し、「最後の履歴を取り消す」で戻す → 「やり直す」で新しいゲーム
  - アカウント・ユーザーの投稿・課金は無いので、それらの流れは撮りません（メモにもそう書いています）。機能を足したら（課金など）、その流れも撮ります

**審査に出す前に App Store Connect で手入力するもの**

API が無い・リリースの判断が要るなど、ワークフローで反映できないものです。`Metadata/App Store` の最後にも一覧が出ます。

| 項目 | 理由・手順 |
|---|---|
| App Review に関する情報の添付ファイル（実機の画面収録） | API で反映していません。上の手順で撮って添付します |
| App のプライバシー（収集するデータの申告） | API がありません。[Numer0nLens/PrivacyInfo.xcprivacy](Numer0nLens/PrivacyInfo.xcprivacy)（データの収集なし）とプライバシーポリシーに合わせて答えます |
| ビルドの選択と審査への提出 | リリースの判断なので人が行います。輸出コンプライアンスは `ITSAppUsesNonExemptEncryption`（`NO`、[Configs/Project.xcconfig](Configs/Project.xcconfig)）で申告済みです |
| デジタルサービス法（EU）の取引業者の情報 | アカウントで一度だけ行います。登録済みなら不要です |

流す順は、`Metadata/App Store` を dry-run で実行して Job Summary の差分を確かめ → `dry_run` を外して実行 → 最後に出る「審査に出す前に App Store Connect で入力が要るもの」を App Store Connect で埋める、です。

## 構成

```
.
├── AppStore/                # App Store の掲載情報の元ネタ（撮影設定・言語・説明文・クリエイティブアセット）
├── Configs/                 # xcconfig（署名情報・バージョン・Deployment Target）
├── Numer0nLens/             # アプリ本体（SwiftUI。Logic/・Model/・Views/・Screenshot/）
├── Numer0nLensTests/        # Unit テスト（XCTest）
├── Numer0nLensUITests/      # UI テスト（XCTest）
├── Numer0nLens.xcodeproj    # 共有スキーム Numer0nLens を含む
├── Tools/                   # App Store の掲載情報の撮影・検査・反映のスクリプト
├── docs/                    # ExportOptions.plist のサンプル
├── .swiftlint.yml           # SwiftLint 設定
└── .github/
    ├── scripts/             # check-app-store-app.rb（App Store Connect のアプリの有無を確認）
    └── workflows/
        ├── _build.yml       # 共通処理: ビルド + テスト + SwiftLint（workflow_call）
        ├── _archive.yml     # 共通処理: Archive → Export（→ Upload）（workflow_call）
        ├── build.yml        # 全ブランチの push / PR
        ├── archive.yml      # main の push
        ├── upload.yml       # develop / release/** の push
        ├── app-store-screenshots.yml        # スクリーンショットの撮影と反映（release/** から手動）
        ├── app-store-metadata.yml           # 説明文などの反映（手動）
        ├── app-store-creative-assets.yml    # ヘッダーと検索結果の反映（手動）
        ├── verify-app-store-metadata.yml    # PR で AppStore/ を検査
        └── close-goal-discussion.yml  # epic の最終 PR のマージでゴール元の Discussion を閉じる
```
