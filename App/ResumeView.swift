import SwiftUI
import ScoreEngine

/// Ao abrir o app com uma partida salva: onde ela parou e quando começou.
struct ResumeView: View {
    let match: Match
    let onDiscard: () -> Void
    let onResume: () -> Void

    var body: some View {
        ConfirmationLayout(title: "Retomar partida?") {
            Group {
                if let startedAt = match.startedAt {
                    Text("\(match.state.resumeSummary). Começou às \(startedAt, format: .dateTime.hour().minute().locale(Locale(identifier: "pt_BR"))).")
                } else {
                    Text(verbatim: match.state.resumeSummary)
                }
            }
            .font(.system(size: 12))
            .foregroundStyle(Color.ink3)
        } buttons: {
            HStack(spacing: 8) {
                PillButton(title: "Descartar", action: onDiscard)
                PillButton(title: "Retomar", primary: true, action: onResume)
            }
        }
    }
}
