/// Algo que aconteceu na partida e entra no log.
public enum MatchEvent: Hashable, Sendable, Codable {
    case point(Team)
}
