import SwiftUI
import ScoreEngine

/// "Quem saca?" no início do set, ou "Quem saca por Eles?" na primeira vez que a outra dupla saca.
struct ServerChoiceView: View {
    let choice: ServerChoice
    let onChoose: (Player) -> Void

    var body: some View {
        // Sem ScrollView: a Crown fica reservada para desfazer, e as opções cabem na tela.
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.white)
            if case .firstServer = choice {
                Text("Primeiro saque da dupla neste set")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.ink3)
            }
            ForEach(players, id: \.self) { player in
                option(player)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.black)
    }

    private var title: LocalizedStringKey {
        switch choice {
        case .openingServer: "Quem saca?"
        case .firstServer(of: let team): team == .us ? "Quem saca por Nós?" : "Quem saca por Eles?"
        }
    }

    private var players: [Player] {
        switch choice {
        case .openingServer: Player.allCases
        case .firstServer(of: let team): Player.players(of: team)
        }
    }

    /// No início do set, Eu vem destacado: é quem usa o relógio e o caso mais comum.
    private func isHighlighted(_ player: Player) -> Bool {
        choice == .openingServer && player == .me
    }

    private func option(_ player: Player) -> some View {
        Button {
            onChoose(player)
        } label: {
            HStack {
                Text(player.label)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(isHighlighted(player) ? Color.accent : Color.white)
                Spacer(minLength: 4)
                if case .openingServer = choice {
                    Text(player.team.label)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.ink3)
                }
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: 36)
            .overlay(
                Capsule().stroke(isHighlighted(player) ? Color.accent : Color.rule, lineWidth: isHighlighted(player) ? 2 : 1)
            )
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
