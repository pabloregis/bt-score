import SwiftUI
import ScoreEngine

/// Confirmação de desfazer: a dupla do último ponto e o placar antes e depois.
struct UndoView: View {
    let preview: UndoPreview
    let onCancel: () -> Void
    let onUndo: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Desfazer?")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.white)
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
            Spacer(minLength: 0)
            HStack(spacing: 8) {
                Button(action: onCancel) {
                    Text("Não")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(Color.rule, in: Capsule())
                }
                Button(action: onUndo) {
                    Text("Desfazer")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.black)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(Color.white, in: Capsule())
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.black)
    }
}
