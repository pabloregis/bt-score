import SwiftUI
import ScoreEngine

/// Placar dividido: tocar na metade de cima marca ponto para Nós, na de baixo para Eles.
struct ScoreboardView: View {
    @State private var match = Match()

    var body: some View {
        let state = match.state
        VStack(spacing: 0) {
            TeamHalf(
                label: "Nós",
                score: state.gameScore(for: .us),
                games: state.games(for: .us),
                isOpponent: false
            ) {
                match.record(.point(.us))
            }
            Rectangle()
                .fill(Color.rule)
                .frame(height: 1)
                .padding(.horizontal, 16)
            TeamHalf(
                label: "Eles",
                score: state.gameScore(for: .them),
                games: state.games(for: .them),
                isOpponent: true
            ) {
                match.record(.point(.them))
            }
        }
        .background(Color.black)
    }
}

private struct TeamHalf: View {
    let label: LocalizedStringKey
    let score: GameScore
    let games: Int
    let isOpponent: Bool
    let onPoint: () -> Void

    var body: some View {
        Button(action: onPoint) {
            HStack(spacing: 10) {
                Text(verbatim: score.display)
                    .font(.system(size: 64, weight: .light))
                    .monospacedDigit()
                    .foregroundStyle(isOpponent ? Color.ink2 : Color.white)
                    .frame(width: 84, alignment: .leading)
                VStack(alignment: .leading, spacing: 1) {
                    Text(label)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.ink3)
                    Text(games, format: .number)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.white)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Toque para marcar ponto")
    }
}

private extension GameScore {
    var display: String {
        switch self {
        case .love: "0"
        case .fifteen: "15"
        case .thirty: "30"
        case .forty: "40"
        }
    }
}
