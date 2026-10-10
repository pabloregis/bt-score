import SwiftUI
import ScoreEngine

/// Uma partida do início ao resultado. "Concluir" no resultado começa outra.
/// Girar a Digital Crown no placar ou no resultado pede para desfazer o último ponto.
struct MatchView: View {
    /// Quanto a Crown precisa girar para abrir a confirmação; um toque acidental fica abaixo disso.
    private static let undoCrownThreshold = 2.0

    @State private var match = Match()
    /// Momento do primeiro ponto; a duração conta a partir dele.
    @State private var startedAt: Date?
    @State private var finishedAt: Date?
    @State private var undoPreview: UndoPreview?
    @State private var crown = 0.0

    var body: some View {
        if let undoPreview {
            UndoView(preview: undoPreview) {
                self.undoPreview = nil
            } onUndo: {
                undo()
                self.undoPreview = nil
            }
        } else {
            matchScreen
                .focusable()
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
                    undoPreview = match.undoPreview
                }
        }
    }

    @ViewBuilder
    private var matchScreen: some View {
        let state = match.state
        if let startedAt, let finishedAt, state.isOver {
            ResultView(state: state, startedAt: startedAt, finishedAt: finishedAt) {
                match = Match()
                self.startedAt = nil
                self.finishedAt = nil
            }
        } else {
            ScoreboardView(state: state) { team in
                let now = Date.now
                if startedAt == nil { startedAt = now }
                match.record(.point(team))
                if match.state.isOver { finishedAt = now }
            }
        }
    }

    /// Desfaz o último ponto. A partida volta a ficar em andamento e, com o log vazio, a duração zera.
    private func undo() {
        match.undo()
        finishedAt = nil
        if match.events.isEmpty { startedAt = nil }
    }
}
