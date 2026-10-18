//
//  DeductionView.swift
//  Numer0nLens
//

import SwiftUI

/// 推理の画面。コールと回答を入力して履歴に足し、履歴と残り候補数を表示する。
struct DeductionView: View {
    let deduction: Deduction
    let role: Role

    /// どちらの推理か。文言と、最善手を出すかが変わる。
    enum Role {
        /// 自分の推理: 自分のコールと相手の回答から、相手の数字を当てる。
        case mine
        /// 相手の推理: 相手のコールと自分の回答から、相手から見た自分の数字の候補を出す。
        case opponent

        var description: String {
            switch self {
            case .mine: "自分のコールと相手の回答から、相手の数字の候補を出します。"
            case .opponent: "相手のコールと自分の回答から、相手から見た自分の数字の候補を出します。相手がどこまで絞れているかの目安になります。"
            }
        }

        var inputTitle: String {
            switch self {
            case .mine: "自分のコールと相手の回答"
            case .opponent: "相手のコールと自分の回答"
            }
        }

        func solvedMessage(length: Int) -> String {
            switch self {
            case .mine: "当たりました（\(length)EAT）"
            case .opponent: "相手に当てられました（\(length)EAT）"
            }
        }

        /// 最善手は自分がコールするときにだけ使う。
        var showsBestMove: Bool {
            self == .mine
        }
    }

    @State private var input = CallInput()
    @FocusState private var isNumberFieldFocused: Bool

    private var rule: Rule { deduction.rule }

    private var validation: Result<HistoryEntry, CallInput.Problem>? {
        input.validate(rule: rule)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.large) {
                CandidateCountCard(count: deduction.candidateCount, description: role.description)

                contradictionCard

                if deduction.isSolved {
                    Card {
                        Label(role.solvedMessage(length: rule.length), systemImage: "checkmark.seal.fill")
                            .font(.headline)
                            .foregroundStyle(Palette.success)
                        Text("続けるときは、右上の「やり直す」から新しいゲームを始めてください。")
                            .font(.footnote)
                            .foregroundStyle(Palette.inkSecondary)
                    }
                } else {
                    inputCard

                    if role.showsBestMove {
                        // 最善手の見た目は後続のタスクで作り直す。ここではカードに載せるだけにする。
                        Card {
                            BestMoveSection(deduction: deduction) { guess in
                                input.text = guess.description
                            }
                        }
                    }
                }

                historyCard

                // 残り候補の見た目は後続のタスクで作り直す。ここではカードに載せるだけにする。
                Card {
                    CandidatePreviewSection(candidates: deduction.candidates)
                }
            }
            .padding(Spacing.large)
        }
        .paperBackground()
        // テンキーには return キーが無いので、スクロールとキーボード上の「完了」で閉じられるようにする。
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("完了") {
                    isNumberFieldFocused = false
                }
                .accessibilityIdentifier("keyboardDoneButton")
            }
        }
    }

    private var inputCard: some View {
        Card(role.inputTitle) {
            numberField
            resultPicker(kind: .eat, selection: $input.eat)
            resultPicker(kind: .bite, selection: $input.bite)
            if case let .failure(problem) = validation {
                Label(problem.message(for: rule), systemImage: "exclamationmark.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(Palette.danger)
            }
            Button("履歴に追加", action: add)
                .buttonStyle(.primary)
                .disabled(!canAdd)
        }
    }

    /// コールを入れる欄。入力方式（数字キーボードのテキスト欄）は変えず、数字タイルの面に見せる。
    private var numberField: some View {
        let shape = RoundedRectangle(cornerRadius: Radius.tile, style: .continuous)
        return TextField(
            "\(rule.length) 桁の数字",
            text: $input.text,
            // El Messiri に日本語の字形は無いので、案内の文は端末のフォントで出す（数字のフォントで出すと別の字形で描かれる）。
            prompt: Text("\(rule.length) 桁の数字")
                .font(.title3.weight(.semibold))
                .tracking(0)
                .foregroundStyle(Palette.inkSecondary)
        )
        .keyboardType(.numberPad)
        .font(Typography.display(size: 32, relativeTo: .title))
        .tracking(6)
        .multilineTextAlignment(.center)
        .foregroundStyle(Palette.ink)
        .padding(.vertical, Spacing.small)
        .padding(.horizontal, Spacing.medium)
        .background(Palette.tileFace, in: shape)
        .overlay {
            shape.strokeBorder(
                isNumberFieldFocused ? Palette.brand : Palette.tileEdge,
                lineWidth: isNumberFieldFocused ? 2 : 1
            )
        }
        .focused($isNumberFieldFocused)
        .accessibilityIdentifier("numberField")
        // 桁数ぶん入力したら閉じて、EAT / BITE を選びやすくする。
        // 「履歴に追加」で空に戻したときは閉じない（開き直したキーボードを残す）。
        .onChange(of: input.text) { _, newText in
            if newText.count >= rule.length {
                isNumberFieldFocused = false
            }
        }
    }

    private func resultPicker(kind: EatBitePill.Kind, selection: Binding<Int>) -> some View {
        let label = Label(kind.title, systemImage: kind.symbol)
            .font(Typography.badge)
            .foregroundStyle(kind.color)
        let picker = Picker(kind.title, selection: selection) {
            ForEach(0...rule.length, id: \.self) { value in
                Text("\(value)").tag(value)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        return HStack(spacing: Spacing.medium) {
            label
                .frame(minWidth: 72, alignment: .leading)
            picker
        }
    }

    private var historyCard: some View {
        Card("履歴") {
            if deduction.history.isEmpty {
                Text("まだ履歴はありません。")
                    .foregroundStyle(Palette.inkSecondary)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(deduction.history.enumerated()), id: \.offset) { index, entry in
                        if index > 0 {
                            Divider()
                                .overlay(Palette.line)
                        }
                        HistoryRow(number: index + 1, entry: entry, isContradiction: index == deduction.contradictionIndex)
                            .padding(.vertical, Spacing.small)
                    }
                }
                Button("最後の履歴を取り消す", role: .destructive) {
                    deduction.undoLast()
                }
                .buttonStyle(.secondary)
            }
        }
    }

    /// 候補が 0 件になったときの知らせ。どの入力で矛盾したかを示す。
    @ViewBuilder
    private var contradictionCard: some View {
        if let index = deduction.contradictionIndex {
            Card {
                Label("候補が 0 通りになりました", systemImage: "exclamationmark.triangle.fill")
                    .font(.headline)
                    .foregroundStyle(Palette.danger)
                Text("履歴の \(index + 1) 件目の入力が、それより前の入力と矛盾しています。コールか回答の入れ間違いがないか確かめ、最後の履歴から取り消してください。")
                    .font(.footnote)
                    .foregroundStyle(Palette.inkSecondary)
            }
        }
    }

    private var canAdd: Bool {
        if case .success = validation {
            return true
        }
        return false
    }

    private func add() {
        guard case let .success(entry) = validation else {
            return
        }
        deduction.add(entry)
        input.clear()
        isNumberFieldFocused = !deduction.isSolved
    }
}

/// 履歴の 1 行。コールを数字タイルで、回答を EAT / BITE のバッジで見せる。
struct HistoryRow: View {
    let number: Int
    let entry: HistoryEntry
    /// この入力で候補が 0 件になったか。
    var isContradiction = false

    /// 行の番号の幅。2 段に折り返したとき、回答をタイルの頭にそろえる。
    private static let numberWidth: CGFloat = 20

    var body: some View {
        switch entry {
        case let .call(guess, result):
            // 5 桁など横に収まらないときは、回答を次の行に下ろす。
            ViewThatFits(in: .horizontal) {
                HStack(spacing: Spacing.small) {
                    call(guess)
                    Spacer(minLength: 0)
                    answer(result)
                }
                VStack(alignment: .leading, spacing: Spacing.small) {
                    call(guess)
                    answer(result)
                        .padding(.leading, Self.numberWidth + Spacing.small)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)
        }
    }

    private func call(_ guess: Numer0nNumber) -> some View {
        HStack(spacing: Spacing.small) {
            Text("\(number)")
                .font(Typography.display(size: 15, weight: .semibold, relativeTo: .subheadline))
                .foregroundStyle(Palette.inkSecondary)
                .frame(minWidth: Self.numberWidth, alignment: .trailing)
                .accessibilityLabel("\(number) 件目")
            DigitTiles(text: guess.description, size: .small)
        }
    }

    private func answer(_ result: EatBite) -> some View {
        HStack(spacing: Spacing.small) {
            EatBiteBadge(result: result, size: .small)
            if isContradiction {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(Palette.danger)
                    .accessibilityLabel("この入力で候補が 0 通りになりました")
            }
        }
    }
}

/// 残り候補の数を大きく見せるカード。
struct CandidateCountCard: View {
    let count: Int
    let description: String

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: Spacing.extraSmall) {
                Text("残り候補")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Palette.inkSecondary)
                HStack(alignment: .firstTextBaseline, spacing: Spacing.small) {
                    Text(count.formatted())
                        .font(Typography.display(size: 44, relativeTo: .largeTitle))
                        .foregroundStyle(Palette.ink)
                        .contentTransition(.numericText())
                    Text("通り")
                        .font(.headline)
                        .foregroundStyle(Palette.inkSecondary)
                }
            }
            .accessibilityElement(children: .combine)
            Text(description)
                .font(.footnote)
                .foregroundStyle(Palette.inkSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        DeductionView(deduction: Deduction(rule: Rule(digitCount: .three)), role: .mine)
    }
}
