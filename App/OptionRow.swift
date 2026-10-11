import SwiftUI

/// Opção em pílula com contorno das telas de escolha: título à esquerda, detalhe cinza à direita.
/// A opção destacada (pré-selecionada) fica em laranja.
struct OptionRow: View {
    let title: LocalizedStringKey
    var detail: LocalizedStringKey?
    var highlighted = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(highlighted ? Color.accent : Color.white)
                Spacer(minLength: 4)
                if let detail {
                    Text(detail)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.ink3)
                }
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: 36)
            .overlay(
                Capsule().stroke(highlighted ? Color.accent : Color.rule, lineWidth: highlighted ? 2 : 1)
            )
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
