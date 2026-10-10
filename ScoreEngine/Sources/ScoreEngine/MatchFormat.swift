/// Formato da partida. Por enquanto só existe set único com game no-ad;
/// melhor de 3 e o match tie-break entram em tickets futuros.
public struct MatchFormat: Hashable, Sendable, Codable {
    /// Regra do tie-break disputado no 6-6.
    public let setTieBreak: TieBreakRule

    public init(setTieBreak: TieBreakRule) {
        self.setTieBreak = setTieBreak
    }

    /// Set único com tie-break a 7, vantagem de 2 e teto em 10.
    public static let singleSet = MatchFormat(setTieBreak: TieBreakRule(target: 7, margin: 2, cap: 10))
}
