/// O que está sendo disputado no momento.
public enum Phase: Hashable, Sendable {
    /// Game normal, com pontuação 0-15-30-40.
    case game
    /// Tie-break do set, com pontos contados em números.
    case tieBreak
}
