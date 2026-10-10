/// Placar derivado do log de eventos de uma partida.
public struct MatchState: Hashable, Sendable {
    private var gameScores: [Team: GameScore] = [:]
    private var gamesWon: [Team: Int] = [:]

    public func gameScore(for team: Team) -> GameScore {
        gameScores[team, default: .love]
    }

    public func games(for team: Team) -> Int {
        gamesWon[team, default: 0]
    }

    mutating func apply(_ event: MatchEvent) {
        switch event {
        case .point(let team):
            if let next = gameScore(for: team).next {
                gameScores[team] = next
            } else {
                gamesWon[team, default: 0] += 1
                gameScores = [:]
            }
        }
    }
}
