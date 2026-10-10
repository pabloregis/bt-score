/// Placar derivado do log de eventos de uma partida.
public struct MatchState: Hashable, Sendable {
    /// No-ad: quem chega a 4 pontos vence o game, inclusive saindo do 40-40.
    private static let pointsToWinGame = 4

    private var points: [Team: Int] = [:]
    private var games: [Team: Int] = [:]

    public func gameScore(for team: Team) -> GameScore {
        GameScore(points: points[team, default: 0])
    }

    public func games(for team: Team) -> Int {
        games[team, default: 0]
    }

    mutating func apply(_ event: MatchEvent) {
        switch event {
        case .point(let team):
            points[team, default: 0] += 1
            if points[team, default: 0] == Self.pointsToWinGame {
                games[team, default: 0] += 1
                points = [:]
            }
        }
    }
}
