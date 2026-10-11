import SwiftUI
import ScoreEngine

/// Tela inicial: escolher o formato (set único pré-selecionado), começar ou abrir o histórico.
struct NewMatchView: View {
    let onStart: (MatchFormat) -> Void
    let onHistory: () -> Void
    @State private var format = MatchFormat.singleSet

    var body: some View {
        ConfirmationLayout(title: "Nova partida") {
            OptionRow(title: "Set único", detail: "padrão", highlighted: format == .singleSet) {
                format = .singleSet
            }
            OptionRow(title: "Melhor de 3", detail: "3 sets", highlighted: format == .bestOfThree) {
                format = .bestOfThree
            }
        } buttons: {
            HStack(spacing: 8) {
                PillButton(title: "Histórico", action: onHistory)
                PillButton(title: "Começar", primary: true) { onStart(format) }
            }
        }
    }
}
