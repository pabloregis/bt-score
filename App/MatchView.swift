import SwiftUI
import ScoreEngine

/// Uma partida do início ao resultado. "Concluir" no resultado começa outra.
/// Girar a Digital Crown no placar ou no resultado pede para desfazer o último ponto.
/// A partida em andamento fica gravada; ao abrir o app com uma salva, ele pergunta se quer retomá-la.
struct MatchView: View {
    /// Quanto a Crown precisa girar para abrir a confirmação; um toque acidental fica abaixo disso.
    private static let undoCrownThreshold = 2.0

    /// Telas sobrepostas ao placar ou ao resultado.
    private enum Prompt {
        case resume(Match)
        case undo(UndoPreview)
        case end
    }

    private let store: MatchStore
    @State private var workout = WorkoutSession()
    @State private var match = Match()
    @State private var finishedAt: Date?
    @State private var prompt: Prompt?
    @State private var crown = 0.0
    @FocusState private var crownFocused: Bool

    init(store: MatchStore = MatchStore()) {
        self.store = store
        _prompt = State(initialValue: store.load().map(Prompt.resume))
    }

    var body: some View {
        Group {
            switch prompt {
            case .resume(let saved):
                ResumeView(match: saved) {
                    store.clear()
                    workout.end()
                    prompt = nil
                } onResume: {
                    match = saved
                    if let startedAt = saved.startedAt { workout.start(matchStart: startedAt) }
                    prompt = nil
                }
            case .undo(let preview):
                UndoView(
                    preview: preview,
                    onCancel: { prompt = nil },
                    onUndo: {
                        match.undo()
                        finishedAt = nil
                        prompt = nil
                    },
                    onEnd: match.state.isOver ? nil : { prompt = .end }
                )
            case .end:
                EndMatchView {
                    prompt = nil
                } onEnd: {
                    match = Match()
                    workout.end()
                    prompt = nil
                }
            case nil:
                crownControlled(matchScreen)
            }
        }
        .onChange(of: match) { _, match in
            store.update(match)
        }
        .task {
            await workout.requestAuthorization()
        }
    }

    private func crownControlled(_ screen: some View) -> some View {
        screen
            .focusable()
            .focusEffectDisabled()
            .focused($crownFocused)
            .onAppear { crownFocused = true }
            .digitalCrownRotation(
                $crown,
                from: -Self.undoCrownThreshold * 2,
                through: Self.undoCrownThreshold * 2,
                sensitivity: .low,
                isContinuous: true,
                isHapticFeedbackEnabled: false
            )
            .onChange(of: crown) { _, value in
                guard abs(value) >= Self.undoCrownThreshold else { return }
                crown = 0
                prompt = match.undoPreview.map(Prompt.undo)
            }
    }

    @ViewBuilder
    private var matchScreen: some View {
        let state = match.state
        if let startedAt = match.startedAt, let finishedAt, state.isOver {
            ResultView(state: state, startedAt: startedAt, finishedAt: finishedAt) {
                match = Match()
                self.finishedAt = nil
            }
        } else {
            ScoreboardView(state: state) { team in
                let now = Date.now
                match.record(.point(team), at: now)
                if let startedAt = match.startedAt { workout.start(matchStart: startedAt) }
                if match.state.isOver {
                    finishedAt = now
                    workout.end()
                }
            }
        }
    }
}
