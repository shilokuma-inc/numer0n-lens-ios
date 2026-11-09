//
//  CandidateListView.swift
//  Numer0nLens
//

import SwiftUI

/// 推理の画面に出す、残り候補の先頭いくつか。全件は `CandidateListView` で見る。
struct CandidatePreviewSection: View {
    let candidates: [Numer0nNumber]

    /// 推理の画面にそのまま並べる件数。これより多ければ「すべて見る」から全件の画面に移る。
    static let previewLimit = 30

    var body: some View {
        Card("残り候補（\(candidates.count.formatted()) 通り）") {
            if candidates.isEmpty {
                Text("候補がありません。")
                    .foregroundStyle(Palette.inkSecondary)
            } else {
                CandidateGrid(candidates: Array(candidates.prefix(Self.previewLimit)))
                if candidates.count > Self.previewLimit {
                    Text("先頭の \(Self.previewLimit) 通りを小さい順に表示しています。")
                        .font(.footnote)
                        .foregroundStyle(Palette.inkSecondary)
                    NavigationLink {
                        CandidateListView(candidates: candidates)
                    } label: {
                        Label("すべて見る（\(candidates.count.formatted()) 通り）", systemImage: "square.grid.3x3")
                    }
                    .buttonStyle(.secondary)
                }
            }
        }
    }
}

/// 候補をタイル風のセルで並べるグリッド。表示される行だけを作る `LazyVGrid` で、数万件でも固まらない。
struct CandidateGrid: View {
    let candidates: [Numer0nNumber]

    private let columns = [GridItem(.adaptive(minimum: 76), spacing: Spacing.small)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.small) {
            ForEach(candidates, id: \.self) { candidate in
                CandidateCell(candidate: candidate)
            }
        }
    }
}

/// 残り候補の 1 つ。数字タイルを小さくしたような面に、数字を El Messiri で出す。
struct CandidateCell: View {
    let candidate: Numer0nNumber

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: Radius.tile - 4, style: .continuous)
        Text(candidate.description)
            .font(Typography.display(size: 19, weight: .semibold, relativeTo: .body))
            .tracking(1.5)
            .foregroundStyle(Palette.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.extraSmall)
            .background {
                shape.fill(Palette.tileFace)
                    .overlay(shape.strokeBorder(Palette.tileEdge, lineWidth: 1))
                    .background(shape.fill(Palette.tileEdge).offset(y: 2))
            }
            .padding(.bottom, 2)
            // 「407」を「よんひゃくなな」と読ませず、1 桁ずつ読ませる。
            .accessibilityLabel(DigitTiles.accessibilityText(for: candidate.description))
    }
}

/// 残り候補の全件。数万件でも固まらないよう、表示される行だけを作る `LazyVGrid` で並べる。
struct CandidateListView: View {
    let candidates: [Numer0nNumber]

    @State private var query = ""

    private var filtered: [Numer0nNumber] {
        guard !query.isEmpty else {
            return candidates
        }
        return candidates.filter { $0.description.hasPrefix(query) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                if !query.isEmpty, !filtered.isEmpty {
                    Text("「\(query)」で始まる候補 \(filtered.count.formatted()) 通り")
                        .font(.footnote)
                        .foregroundStyle(Palette.inkSecondary)
                }
                CandidateGrid(candidates: filtered)
            }
            .padding(Spacing.large)
        }
        .paperBackground()
        .overlay {
            if filtered.isEmpty {
                ContentUnavailableView.search(text: query)
            }
        }
        .searchable(text: $query, prompt: "先頭の数字で絞り込む")
        .navigationTitle("残り候補 \(candidates.count.formatted()) 通り")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            CandidatePreviewSection(candidates: Rule(digitCount: .three).allNumbers())
                .padding()
        }
        .paperBackground()
    }
}
