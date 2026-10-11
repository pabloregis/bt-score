import SwiftUI
import ScoreEngine

/// Da tela de nova partida ao resultado. "Concluir" no resultado volta à nova partida.
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
    private let historyFile: JSONFile<History>
    @State private var history = History()
    @State private var workout = WorkoutSession()
    @State private var match = Match()
    @State private var finishedAt: Date?
    /// Na tela de nova partida, escolhendo o formato.
    @State private var choosingFormat = true
    @State private var showingHistory = false
    @State private var prompt: Prompt?
    @State private var crown = 0.0
    @FocusState private var crownFocused: Bool

    init(directory: URL = .applicationSupportDirectory) {
        store = MatchStore(directory: directory)
        historyFile = JSONFile(name: "historico.json", directory: directory)
        _prompt = State(initialValue: store.load().map(Prompt.resume))
        _history = State(initialValue: historyFile.load() ?? History())
    }

    var body: some View {
        Group {
            switch prompt {
            case .resume(let saved):
                ResumeView(match: saved) {
                    store.clear()
                    startOver(endingWorkout: true)
                } onResume: {
                    match = saved
                    choosingFormat = false
                    if let startedAt = saved.startedAt { workout.start(matchStart: startedAt) }
                    prompt = nil
                }
            case .undo(let preview):
                UndoView(
                    preview: preview,
                    onCancel: { prompt = nil },
                    onUndo: {
                        // Desfazer o ponto final tira a partida do histórico: ela volta a estar em andamento.
                        if match.state.isOver, let startedAt = match.startedAt {
                            history.remove(startedAt: startedAt)
                        }
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
                    startOver(endingWorkout: true)
                }
            case nil where choosingFormat:
                NewMatchView { format in
                    match = Match(format: format)
                    choosingFormat = false
                } onHistory: {
                    showingHistory = true
                }
            case nil:
                crownControlled(matchScreen)
            }
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView(history: history)
        }
        .onChange(of: history) { _, history in
            historyFile.save(history)
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
                if match.events.isEmpty {
                    // Antes de qualquer evento, a Crown volta à nova partida para trocar o formato.
                    choosingFormat = true
                } else if match.lastEventIsServerChoice {
                    // Desfazer uma escolha de sacador só volta à escolha; nada se perde.
                    match.undo()
                } else {
                    prompt = match.undoPreview.map(Prompt.undo)
                }
            }
    }

    @ViewBuilder
    private var matchScreen: some View {
        let state = match.state
        if let choice = state.awaitingServerChoice {
            ServerChoiceView(choice: choice, suggested: state.suggestedOpeningServer) { player in
                match.record(choice.event(for: player))
            }
        } else if let startedAt = match.startedAt, let finishedAt, state.isOver {
            ResultView(state: state, startedAt: startedAt, finishedAt: finishedAt) {
                // O treino já terminou com a partida.
                startOver(endingWorkout: false)
            }
        } else {
            ScoreboardView(state: state) { team in
                let now = Date.now
                // Só o toque de ponto aceito vibra; desfazer e as escolhas de sacador ficam em silêncio.
                guard match.record(.point(team), at: now) else { return }
                match.state.lastPointOutcome?.play()
                if let startedAt = match.startedAt { workout.start(matchStart: startedAt) }
                if match.state.isOver {
                    finishedAt = now
                    workout.end()
                    // Grava ao terminar, para não perder a partida se o app fechar no resultado.
                    if let record = MatchRecord(match: match, finishedAt: now) { history.add(record) }
                }
            }
        }
    }

    /// Volta à tela de nova partida, descartando a partida atual.
    private func startOver(endingWorkout: Bool) {
        if endingWorkout { workout.end() }
        match = Match()
        finishedAt = nil
        choosingFormat = true
        prompt = nil
    }
}
