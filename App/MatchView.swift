import SwiftUI
import ScoreEngine

/// Uma partida do início ao resultado. "Concluir" no resultado começa outra.
struct MatchView: View {
    @State private var match = Match()
    @State private var startedAt = Date.now
    @State private var finishedAt: Date?

    var body: some View {
        let state = match.state
        if state.isOver, let finishedAt {
            ResultView(state: state, startedAt: startedAt, finishedAt: finishedAt) {
                match = Match()
                startedAt = .now
                self.finishedAt = nil
            }
        } else {
            ScoreboardView(state: state) { team in
                match.record(.point(team))
                if match.state.isOver { finishedAt = .now }
            }
        }
    }
}
