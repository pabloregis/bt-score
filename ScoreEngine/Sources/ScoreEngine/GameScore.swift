/// Pontuação de uma dupla dentro de um game normal.
public enum GameScore: Hashable, Sendable {
    case love
    case fifteen
    case thirty
    case forty

    /// A pontuação depois de mais um ponto, ou `nil` quando o ponto fecha o game.
    /// No-ad: o ponto marcado com 40 sempre fecha o game, inclusive no 40-40.
    var next: GameScore? {
        switch self {
        case .love: .fifteen
        case .fifteen: .thirty
        case .thirty: .forty
        case .forty: nil
        }
    }

    /// Como o jogador lê: "0", "15", "30" ou "40".
    public var formatted: String {
        switch self {
        case .love: "0"
        case .fifteen: "15"
        case .thirty: "30"
        case .forty: "40"
        }
    }
}
