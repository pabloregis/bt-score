import SwiftUI

/// Confirmação de encerrar a partida antes do fim: ela é descartada.
struct EndMatchView: View {
    let onCancel: () -> Void
    let onEnd: () -> Void

    var body: some View {
        ConfirmationLayout(title: "Encerrar partida?") {
            Text("A partida é descartada.")
                .font(.system(size: 13))
                .foregroundStyle(Color.ink2)
        } buttons: {
            HStack(spacing: 8) {
                PillButton(title: "Não", action: onCancel)
                PillButton(title: "Encerrar", primary: true, action: onEnd)
            }
        }
    }
}
