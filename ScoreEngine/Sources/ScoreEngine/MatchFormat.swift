/// Formato da partida. Por enquanto só existe set único com game no-ad;
/// melhor de 3 e os parâmetros de tie-break entram em tickets futuros.
public enum MatchFormat: Hashable, Sendable, Codable {
    case singleSet
}
