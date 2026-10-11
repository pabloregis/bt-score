import SwiftUI

/// Partidas anteriores. A lista entra com o histórico (PAB-13); por enquanto, só o estado vazio.
struct HistoryView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Histórico")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.white)
            Text("Ainda não há partidas.")
                .font(.system(size: 13))
                .foregroundStyle(Color.ink3)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.black)
    }
}
