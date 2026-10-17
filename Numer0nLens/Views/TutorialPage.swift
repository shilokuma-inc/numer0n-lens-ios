//
//  TutorialPage.swift
//  Numer0nLens
//

/// チュートリアルの 1 ページ分の内容。文言とアイコンを View から切り離して持つ。
struct TutorialPage: Identifiable, Hashable {
    let id: Kind
    /// SF Symbols の名前。
    let systemImage: String
    let title: String
    /// 本文の段落。
    let paragraphs: [String]

    enum Kind: Hashable, CaseIterable {
        case overview
        case rule
        case sides
        case input
        case bestMove
        case trouble
    }
}

extension TutorialPage {
    /// 表示する順番に並べたページ。ルールの説明は 1 枚にとどめ、残りはアプリの使い方に充てる。
    static let all: [Self] = [
        Self(
            id: .overview,
            systemImage: "rectangle.and.pencil.and.ellipsis",
            title: "このアプリでできること",
            paragraphs: [
                "ヌメロン解析は、相手との対戦を横で記録していくアプリです。",
                "対戦は相手と直接進め、コールと回答をこのアプリに書き写します。入れるたびに、残っている数字の候補を絞り込みます。"
            ]
        ),
        Self(
            id: .rule,
            systemImage: "number.square",
            title: "ルールのおさらい",
            paragraphs: [
                "おたがいに 0〜9 の数字を重複なしで並べた数を決め、交互にコールして、先に相手の数を当てたほうが勝ちです。",
                "EAT は数字も位置も合っている数、BITE は数字は合っているが位置が違う数です。",
                "例: 相手の数が 123 で 135 とコールしたら、1 が EAT、3 が BITE なので「1EAT 1BITE」です。"
            ]
        ),
        Self(
            id: .sides,
            systemImage: "person.2",
            title: "自分の推理と相手の推理",
            paragraphs: [
                "画面の上で「自分の推理」と「相手の推理」を切り替えます。",
                "自分の推理には、自分のコールと相手の回答を入れます。相手の数の候補が絞られます。",
                "相手の推理には、相手のコールと自分の回答を入れます。相手から見た自分の数の候補が分かります。",
                "上の比較では、残りの候補が少ないほうが当てるのに近いことを表します。"
            ]
        ),
        Self(
            id: .input,
            systemImage: "square.and.pencil",
            title: "コールと回答を入れる",
            paragraphs: [
                "コールした数字を入れ、EAT と BITE の数を選んで「履歴に追加」を押します。",
                "コールのたびに 1 件ずつ足していくと、残りの候補の数と一覧が更新されます。"
            ]
        ),
        Self(
            id: .bestMove,
            systemImage: "lightbulb",
            title: "最善手の読み方",
            paragraphs: [
                "「自分の推理」には、次にコールすると良い手が「最善手」として出ます。",
                "情報量（bit）が大きい手ほど、相手の回答で候補を大きく絞れます。",
                "手をタップすると入力欄に入るので、そのままコールに使えます。"
            ]
        ),
        Self(
            id: .trouble,
            systemImage: "arrow.uturn.backward.circle",
            title: "困ったとき",
            paragraphs: [
                "候補が 0 通りになったら、どこかで入れ間違えています。間違えた入力まで「最後の履歴を取り消す」で順に戻し、入れ直してください。",
                "右上の「やり直す」から、「同じ桁数でやり直す」で履歴を消して新しいゲームを始め、「桁数を選び直す」でスタート画面に戻ります。"
            ]
        )
    ]
}
