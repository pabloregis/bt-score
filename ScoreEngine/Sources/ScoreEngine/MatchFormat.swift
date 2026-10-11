/// Formato da partida: set único ou melhor de 3, sempre com game no-ad.
public struct MatchFormat: Hashable, Sendable, Codable {
    /// Sets para vencer a partida: 1 no set único, 2 no melhor de 3.
    public let setsToWin: Int
    /// Regra do tie-break disputado no 6-6.
    public let setTieBreak: TieBreakRule
    /// Regra do match tie-break que substitui o set decisivo; `nil` para jogá-lo como set normal.
    public let matchTieBreak: TieBreakRule?

    public init(setsToWin: Int = 1, setTieBreak: TieBreakRule, matchTieBreak: TieBreakRule? = nil) {
        precondition(setsToWin > 0, "a partida precisa de ao menos um set")
        self.setsToWin = setsToWin
        self.setTieBreak = setTieBreak
        self.matchTieBreak = matchTieBreak
    }

    private static let standardTieBreak = TieBreakRule(target: 7, margin: 2, cap: 10)

    /// Set único com tie-break a 7, vantagem de 2 e teto em 10.
    public static let singleSet = MatchFormat(setTieBreak: standardTieBreak)

    /// Melhor de 3: no 1-1, o terceiro set vira match tie-break a 10, vantagem de 2, sem teto.
    public static let bestOfThree = MatchFormat(
        setsToWin: 2,
        setTieBreak: standardTieBreak,
        matchTieBreak: TieBreakRule(target: 10, margin: 2, cap: nil)
    )
}

extension MatchFormat {
    private enum CodingKeys: String, CodingKey {
        case setsToWin, setTieBreak, matchTieBreak
    }

    /// Partidas salvas antes do melhor de 3 não têm `setsToWin`: são de set único.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            setsToWin: try container.decodeIfPresent(Int.self, forKey: .setsToWin) ?? 1,
            setTieBreak: try container.decode(TieBreakRule.self, forKey: .setTieBreak),
            matchTieBreak: try container.decodeIfPresent(TieBreakRule.self, forKey: .matchTieBreak)
        )
    }
}
