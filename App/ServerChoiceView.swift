import SwiftUI
import ScoreEngine

/// "Quem saca?" no início de cada set, ou "Quem saca por Eles?" na primeira vez que a outra dupla saca.
struct ServerChoiceView: View {
    let choice: ServerChoice
    /// Jogador pré-selecionado, destacado em laranja.
    let suggested: Player?
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
                OptionRow(
                    title: player.label,
                    detail: choice == .openingServer ? player.team.label : nil,
                    highlighted: player == suggested
                ) {
                    onChoose(player)
                }
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
}
