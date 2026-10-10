import SwiftUI
import ScoreEngine

/// Confirmação de desfazer: a dupla do último ponto e o placar antes e depois.
/// Com a partida em andamento, também oferece encerrá-la antes do fim.
struct UndoView: View {
    let preview: UndoPreview
    let onCancel: () -> Void
    let onUndo: () -> Void
    /// `nil` quando a partida já acabou: aí não há o que encerrar.
    let onEnd: (() -> Void)?

    var body: some View {
        ConfirmationLayout(title: "Desfazer?") {
            if preview.isTieBreak {
                Text("tie-break")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.accent)
            }
            Text("Último ponto: \(Text(preview.team.label))")
                .font(.system(size: 13))
                .foregroundStyle(Color.ink2)
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text(verbatim: preview.before)
                    .foregroundStyle(Color.ink3)
                    .strikethrough(color: Color.ink3)
                Text(verbatim: "→")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.ink3)
                    .accessibilityHidden(true)
                Text(verbatim: preview.after)
                    .foregroundStyle(Color.white)
            }
            .font(.system(size: 30, weight: .light))
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.6)
        } buttons: {
            HStack(spacing: 8) {
                PillButton(title: "Não", action: onCancel)
                PillButton(title: "Desfazer", primary: true, action: onUndo)
            }
            if let onEnd {
                Button(action: onEnd) {
                    Text("Encerrar partida")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.ink3)
                        .frame(maxWidth: .infinity, minHeight: 28)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
