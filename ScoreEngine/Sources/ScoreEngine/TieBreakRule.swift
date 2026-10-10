/// Quando um tie-break termina.
public struct TieBreakRule: Hashable, Sendable, Codable {
    /// Pontos mínimos para vencer.
    public let target: Int
    /// Vantagem mínima sobre a outra dupla.
    public let margin: Int
    /// Pontuação que vence mesmo sem a vantagem mínima; `nil` para sem teto.
    public let cap: Int?

    public init(target: Int, margin: Int, cap: Int?) {
        precondition(target > 0, "o alvo do tie-break precisa ser positivo")
        precondition(margin > 0, "a vantagem mínima do tie-break precisa ser positiva")
        precondition(cap.map { $0 >= target } ?? true, "o teto do tie-break não pode ser menor que o alvo")
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
