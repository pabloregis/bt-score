import SwiftUI
import ScoreEngine

/// Partidas anteriores, da mais recente para a mais antiga: placar do ponto de vista de Nós e data.
struct HistoryView: View {
    let history: History

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                Text("Histórico")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.white)
                if history.records.isEmpty {
                    Text("Ainda não há partidas.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.ink3)
                }
                ForEach(history.records, id: \.startedAt) { record in
                    HistoryRow(record: record)
                }
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.black)
    }
}

private struct HistoryRow: View {
    let record: MatchRecord

    var body: some View {
        let won = record.winner == .us
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: record.resultLine)
                .font(.system(size: 15, weight: .medium))
                .monospacedDigit()
                .foregroundStyle(won ? Color.white : Color.ink2)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Text("\(won ? Text("Vitória") : Text("Derrota")) · \(record.startedAt, format: .dateTime.day().month(.abbreviated))")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.ink3)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.rule).frame(height: 1)
        }
        .accessibilityElement(children: .combine)
    }
}
