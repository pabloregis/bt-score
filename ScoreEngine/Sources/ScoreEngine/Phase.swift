/// O que está sendo disputado no momento.
public enum Phase: Hashable, Sendable {
    /// Game normal, com pontuação 0-15-30-40.
    case game
    /// Tie-break do set, com pontos contados em números.
    case tieBreak
    /// Match tie-break que substitui o set decisivo no melhor de 3, também contado em números.
    case matchTieBreak
    /// A partida acabou.
    case finished

    /// Pontos contados em números, com o rodízio de saque 1-2-2.
    public var isTieBreak: Bool { self == .tieBreak || self == .matchTieBreak }
}
