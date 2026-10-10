import SwiftUI

/// Botão em pílula das telas de confirmação: branco para a ação principal, cinza para a secundária.
struct PillButton: View {
    let title: LocalizedStringKey
    var primary = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(primary ? Color.black : Color.white)
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(primary ? Color.white : Color.rule, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

/// Layout comum das telas de confirmação: título, conteúdo e botões no rodapé.
struct ConfirmationLayout<Content: View, Buttons: View>: View {
    let title: LocalizedStringKey
    @ViewBuilder let content: Content
    @ViewBuilder let buttons: Buttons

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.white)
            content
            Spacer(minLength: 0)
            buttons
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.black)
    }
}
