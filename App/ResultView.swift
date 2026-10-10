import SwiftUI
import ScoreEngine

/// Fim da partida: vitória ou derrota, placar do ponto de vista de Nós, data de início e duração.
struct ResultView: View {
    let state: MatchState
    let startedAt: Date
    let finishedAt: Date
    let onDone: () -> Void

    var body: some View {
        let won = state.winner == .us
        VStack(alignment: .leading, spacing: 6) {
            Text(won ? LocalizedStringKey("Vitória") : LocalizedStringKey("Derrota"))
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(won ? Color.white : Color.ink2)
            ForEach(Array(state.sets.enumerated()), id: \.offset) { _, set in
                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    Text(verbatim: set.gamesFormatted)
                        .font(.system(size: 48, weight: .light))
                        .tracking(-1.5)
                        .monospacedDigit()
                        .foregroundStyle(Color.white)
                    if let tieBreak = set.tieBreak {
                        Text(verbatim: tieBreak.formatted)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.ink3)
                    }
                }
            }
            Text("\(startedAt, format: .dateTime.day().month(.abbreviated)) · \(duration, format: .units(allowed: [.hours, .minutes], width: .abbreviated))")
                .font(.system(size: 12))
                .foregroundStyle(Color.ink3)
            Spacer(minLength: 0)
            Button(action: onDone) {
                Text("Concluir")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.black)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(Color.white, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.black)
    }

    private var duration: Duration {
        .seconds(finishedAt.timeIntervalSince(startedAt))
    }
}
