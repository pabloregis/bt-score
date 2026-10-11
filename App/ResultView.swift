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
            if let set = state.sets.first, state.sets.count == 1 {
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
            } else {
                // Melhor de 3: os sets em sequência, "6-3 4-6 [10-7]", encolhendo para caber.
                Text(verbatim: state.resultLine)
                    .font(.system(size: 28, weight: .light))
                    .monospacedDigit()
                    .foregroundStyle(Color.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
            }
            Text("\(startedAt, format: .dateTime.day().month(.abbreviated)) · \(duration, format: .units(allowed: [.hours, .minutes], width: .abbreviated))")
                .font(.system(size: 12))
                .foregroundStyle(Color.ink3)
            Spacer(minLength: 0)
            PillButton(title: "Concluir", primary: true, action: onDone)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.black)
    }

    private var duration: Duration {
        .seconds(finishedAt.timeIntervalSince(startedAt))
    }
}
