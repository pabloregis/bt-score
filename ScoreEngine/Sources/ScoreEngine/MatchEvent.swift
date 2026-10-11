/// Algo que aconteceu na partida e entra no log.
public enum MatchEvent: Hashable, Sendable, Codable {
    case point(Team)
    /// Quem abre o set.
    case openingServer(Player)
    /// Quem saca primeiro pela outra dupla, na primeira vez que ela saca no set.
    case firstServer(Player)
}
