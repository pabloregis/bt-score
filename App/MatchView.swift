import SwiftUI
import ScoreEngine

/// Uma partida do início ao resultado. "Concluir" no resultado começa outra.
struct MatchView: View {
    @State private var match = Match()
    /// Momento do primeiro ponto; a duração conta a partir dele.
    @State private var startedAt: Date?
    @State private var finishedAt: Date?

    var body: some View {
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
}
