/// Um dos quatro jogadores, com rótulo fixo: Eu e Parceiro em Nós, Adversário 1 e 2 em Eles.
public enum Player: Hashable, Sendable, Codable, CaseIterable {
    case me
    case partner
    case opponent1
    case opponent2

    /// A dupla do jogador.
    public var team: Team {
        switch self {
        case .me, .partner: .us
        case .opponent1, .opponent2: .them
        }
    }

    /// O outro jogador da mesma dupla.
    public var teammate: Player {
        switch self {
        case .me: .partner
        case .partner: .me
        case .opponent1: .opponent2
        case .opponent2: .opponent1
        }
    }

    /// Os dois jogadores da dupla.
    public static func players(of team: Team) -> [Player] {
        team == .us ? [.me, .partner] : [.opponent1, .opponent2]
    }
}

/// Escolha de sacador que a partida aguarda antes de aceitar pontos.
public enum ServerChoice: Hashable, Sendable {
    /// Quem abre o set, entre os quatro jogadores.
    case openingServer
    /// Qual jogador da dupla saca primeiro, na primeira vez que ela vai sacar no set.
    case firstServer(of: Team)
}
