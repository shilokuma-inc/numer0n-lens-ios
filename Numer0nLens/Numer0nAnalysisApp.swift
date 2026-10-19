//
//  Numer0nAnalysisApp.swift
//  Numer0nLens
//

import SwiftUI

@main
struct Numer0nAnalysisApp: App {
    var body: some Scene {
        WindowGroup {
            rootView
        }
    }

    /// 撮影モード（ScreenshotDemo）のときは、撮る画面をデモデータで開く。
    /// ContentView を通さないので、初回起動のチュートリアルは出ない。
    @ViewBuilder private var rootView: some View {
        switch ScreenshotDemo.scene {
        case nil:
            ContentView()
        case .deduction:
            NavigationStack {
                GameView(game: ScreenshotDemo.game) {}
            }
        case .opponent:
            NavigationStack {
                GameView(game: ScreenshotDemo.game, initialSide: .opponent) {}
            }
        case .candidates:
            NavigationStack {
                CandidateListView(candidates: ScreenshotDemo.candidates)
            }
        case .start:
            NavigationStack {
                StartView { _ in }
            }
        case .tutorial:
            TutorialView {}
        }
    }
}
