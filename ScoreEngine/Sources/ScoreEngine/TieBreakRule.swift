/// Quando um tie-break termina.
public struct TieBreakRule: Hashable, Sendable, Codable {
    /// Pontos mínimos para vencer.
    public let target: Int
    /// Vantagem mínima sobre a outra dupla.
    public let margin: Int
    /// Pontuação que vence mesmo sem a vantagem mínima; `nil` para sem teto.
    public let cap: Int?

    public init(target: Int, margin: Int, cap: Int?) {
        self.target = target
        self.margin = margin
        self.cap = cap
    }

    /// Se a dupla com `points` venceu o tie-break contra `opponentPoints`.
    func isWon(points: Int, opponentPoints: Int) -> Bool {
        if let cap, points >= cap { return true }
        return points >= target && points - opponentPoints >= margin
    }
}
