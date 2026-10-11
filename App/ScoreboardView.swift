import SwiftUI
import ScoreEngine

/// Placar dividido: tocar na metade de cima marca ponto para Nós, na de baixo para Eles.
struct ScoreboardView: View {
    let state: MatchState
    let onPoint: (Team) -> Void

    var body: some View {
        VStack(spacing: 0) {
            TeamHalf(team: .us, state: state) { onPoint(.us) }
            Rectangle()
                .fill(Color.rule)
                .frame(height: 1)
                .padding(.horizontal, 16)
            TeamHalf(team: .them, state: state) { onPoint(.them) }
        }
        .background(Color.black)
        .overlay(alignment: .topLeading) {
            if state.phase.isTieBreak {
                Text(state.phase == .matchTieBreak ? "match tie-break" : "tie-break")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.accent)
                    .padding(.horizontal, 16)
                    .allowsHitTesting(false)
            }
        }
    }
}

private struct TeamHalf: View {
    let team: Team
    let state: MatchState
    let onPoint: () -> Void

    var body: some View {
        Button(action: onPoint) {
            HStack(spacing: 10) {
                Text(verbatim: state.pointsFormatted(for: team))
                    .font(.system(size: 64, weight: .light))
                    .tracking(-2.5)
                    .monospacedDigit()
                    .foregroundStyle(team == .them ? Color.ink2 : Color.white)
                    .frame(width: 84, alignment: .leading)
                VStack(alignment: .leading, spacing: 1) {
                    Text(team.label)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.ink3)
                    Text(state.games(for: team), format: .number)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.white)
                    if state.format.setsToWin > 1 {
                        Text("sets \(state.setsWon(for: team))")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.ink3)
                    }
                    if let server = state.server, server.team == team {
                        Group {
                            Text("saca \(Text(server.shortLabel))")
                            if let position = state.servePairPosition {
                                Text("\(position) de 2")
                            }
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.accent)
                        .lineLimit(2)
                    }
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
