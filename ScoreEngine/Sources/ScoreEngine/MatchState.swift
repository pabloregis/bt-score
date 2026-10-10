/// Placar derivado do log de eventos de uma partida.
public struct MatchState: Hashable, Sendable {
    /// Placar de uma dupla no set em andamento.
    private struct TeamScore: Hashable, Sendable {
        var game: GameScore = .love
        var games = 0
        var tieBreakPoints = 0
    }

    private static let gamesToWinSet = 6
    private static let setMargin = 2

    private let format: MatchFormat
    private var scores: [Team: TeamScore] = [.us: TeamScore(), .them: TeamScore()]

    public private(set) var sets: [SetScore] = []
    public private(set) var winner: Team?
    public private(set) var phase: Phase = .game

    public var isOver: Bool { winner != nil }

    init(format: MatchFormat) {
        self.format = format
    }

    public func gameScore(for team: Team) -> GameScore {
        scores[team]!.game
    }

    public func games(for team: Team) -> Int {
        scores[team]!.games
    }

    public func tieBreakPoints(for team: Team) -> Int {
        scores[team]!.tieBreakPoints
    }

    mutating func apply(_ event: MatchEvent) {
        guard !isOver else { return }
        switch event {
        case .point(let team):
            if phase == .tieBreak {
                winTieBreakPoint(team)
            } else if let next = gameScore(for: team).next {
                scores[team]!.game = next
            } else {
                winGame(team)
            }
        }
    }

    private mutating func winTieBreakPoint(_ team: Team) {
        scores[team]!.tieBreakPoints += 1
        let points = scores[team]!.tieBreakPoints
        if format.setTieBreak.isWon(points: points, opponentPoints: scores[team.opponent]!.tieBreakPoints) {
            scores[team]!.games += 1
            let tieBreak = TieBreakScore(us: scores[.us]!.tieBreakPoints, them: scores[.them]!.tieBreakPoints)
            sets.append(SetScore(us: scores[.us]!.games, them: scores[.them]!.games, tieBreak: tieBreak))
            winner = team
        }
    }

    private mutating func winGame(_ team: Team) {
        scores[team]!.games += 1
        scores[.us]!.game = .love
        scores[.them]!.game = .love
        let games = scores[team]!.games
        if games >= Self.gamesToWinSet, games - scores[team.opponent]!.games >= Self.setMargin {
            sets.append(SetScore(us: scores[.us]!.games, them: scores[.them]!.games))
            winner = team
        } else if games == Self.gamesToWinSet, scores[team.opponent]!.games == Self.gamesToWinSet {
            phase = .tieBreak
        }
    }
}
