//
//  ContentView.swift
//  Numer0nLens
//

import SwiftUI

/// ルートの画面。ゲームが始まっていなければ桁数を選ぶ画面を、始まっていればゲームの画面を出す。
/// 初回の起動では、チュートリアルを全画面で出す。
struct ContentView: View {
    /// チュートリアルを表示済みかを保存するキー。
    static let hasSeenTutorialKey = "hasSeenTutorial"
    /// 付いていればチュートリアルを自動で出さない起動引数（UI テスト用）。
    static let skipTutorialArgument = "-skipTutorial"

    @State private var game: GameState?
    @AppStorage(Self.hasSeenTutorialKey) private var hasSeenTutorial = false
    @State private var isShowingTutorial = false
    /// 起動時の判定を済ませたか。cover を閉じると `onAppear` がまた呼ばれることがあるため、判定は 1 回だけにする。
    @State private var didCheckTutorialOnLaunch = false

    var body: some View {
        NavigationStack {
            if let game {
                GameView(game: game) {
                    self.game = nil
                }
            } else {
                StartView { digitCount in
                    game = GameState(digitCount: digitCount)
                }
            }
        }
        .onAppear {
            guard !didCheckTutorialOnLaunch else {
                return
            }
            didCheckTutorialOnLaunch = true
            if Self.shouldShowTutorialOnLaunch(hasSeenTutorial: hasSeenTutorial, arguments: ProcessInfo.processInfo.arguments) {
                isShowingTutorial = true
            }
        }
        // スキップで閉じても表示済みにする。
        .fullScreenCover(
            isPresented: $isShowingTutorial,
            onDismiss: { hasSeenTutorial = true },
            content: {
                TutorialView {
                    hasSeenTutorial = true
                    isShowingTutorial = false
                }
            }
        )
    }

    /// 起動時にチュートリアルを自動で出すか。
    static func shouldShowTutorialOnLaunch(hasSeenTutorial: Bool, arguments: [String]) -> Bool {
        !hasSeenTutorial && !arguments.contains(skipTutorialArgument)
    }
}

#Preview {
    ContentView()
}
