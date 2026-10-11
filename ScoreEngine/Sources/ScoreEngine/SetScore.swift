/// Placar final de um set em games, do ponto de vista de Nós.
public struct SetScore: Hashable, Sendable, Codable {
    public let us: Int
    public let them: Int
    /// Placar do tie-break, quando o set foi decidido nele.
    public let tieBreak: TieBreakScore?
    /// O "set" foi um match tie-break: `us` e `them` são pontos, não games.
    public let isMatchTieBreak: Bool

    public init(us: Int, them: Int, tieBreak: TieBreakScore? = nil, isMatchTieBreak: Bool = false) {
        self.us = us
        self.them = them
        self.tieBreak = tieBreak
        self.isMatchTieBreak = isMatchTieBreak
    }

    /// Placar do set como o jogador lê: "6-4", "7-6 (10-9)" quando decidido no tie-break,
    /// ou "[10-7]" no match tie-break.
    public var formatted: String {
        guard let tieBreak else { return gamesFormatted }
        return "\(gamesFormatted) \(tieBreak.formatted)"
    }

    /// Quem venceu o set.
    public var winner: Team { us > them ? .us : .them }

    /// Só os games: "7-6"; no match tie-break, os pontos entre colchetes: "[10-7]".
    public var gamesFormatted: String {
        isMatchTieBreak ? "[\(us)-\(them)]" : "\(us)-\(them)"
    }
}

/// Placar final de um tie-break em pontos, do ponto de vista de Nós.
public struct TieBreakScore: Hashable, Sendable, Codable {
    public let us: Int
    public let them: Int

    public init(us: Int, them: Int) {
        self.us = us
        self.them = them
    }

    /// O tie-break entre parênteses: "(10-9)".
    public var formatted: String { "(\(us)-\(them))" }
}
