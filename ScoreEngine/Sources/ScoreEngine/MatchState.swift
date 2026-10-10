/// Placar derivado do log de eventos de uma partida.
public struct MatchState: Hashable, Sendable {
    /// Placar de uma dupla no set em andamento.
    private struct TeamScore: Hashable, Sendable {
        var game: GameScore = .love
        var games = 0
        var tieBreakPoints = 0
    }

    /// O placar das duas duplas, acessado pela dupla.
    private struct Scores: Hashable, Sendable {
        var us = TeamScore()
        var them = TeamScore()

        /// Placar do tie-break em andamento, do ponto de vista de Nós.
        var tieBreakScore: TieBreakScore {
            TieBreakScore(us: us.tieBreakPoints, them: them.tieBreakPoints)
        }

        subscript(team: Team) -> TeamScore {
            get { team == .us ? us : them }
            set { if team == .us { us = newValue } else { them = newValue } }
        }
    }

    private static let gamesToWinSet = 6
    private static let setMargin = 2

    private let format: MatchFormat
    private var scores = Scores()

    public private(set) var sets: [SetScore] = []
    public private(set) var winner: Team?
    public private(set) var phase: Phase = .game

    public var isOver: Bool { phase == .finished }

    init(format: MatchFormat) {
        self.format = format
    }

    public func gameScore(for team: Team) -> GameScore {
        scores[team].game
    }

    public func games(for team: Team) -> Int {
        scores[team].games
    }

    public func tieBreakPoints(for team: Team) -> Int {
        scores[team].tieBreakPoints
    }

    /// Pontos da dupla como o jogador lê: 0-15-30-40 no game, a contagem no tie-break.
    public func pointsFormatted(for team: Team) -> String {
        phase == .tieBreak ? "\(tieBreakPoints(for: team))" : gameScore(for: team).formatted
    }

    /// Pontos das duas duplas, do ponto de vista de Nós: "30-15".
    var pointsLine: String {
        "\(pointsFormatted(for: .us))-\(pointsFormatted(for: .them))"
    }

    /// Games do set em andamento, do ponto de vista de Nós: "3-2".
    var gamesLine: String {
        "\(games(for: .us))-\(games(for: .them))"
    }

    mutating func apply(_ event: MatchEvent) {
        guard !isOver else { return }
        switch event {
        case .point(let team):
            if phase == .tieBreak {
                winTieBreakPoint(team)
            } else if let next = gameScore(for: team).next {
                scores[team].game = next
            } else {
                winGame(team)
            }
        }
    }

    private mutating func winTieBreakPoint(_ team: Team) {
        scores[team].tieBreakPoints += 1
        let won = format.setTieBreak.isWon(
            points: scores[team].tieBreakPoints,
            opponentPoints: scores[team.opponent].tieBreakPoints
        )
        if won {
            scores[team].games += 1
            finishSet(winner: team, tieBreak: scores.tieBreakScore)
        }
    }

    private mutating func winGame(_ team: Team) {
        scores[team].games += 1
        scores.us.game = .love
        scores.them.game = .love
        let games = scores[team].games
        let opponentGames = scores[team.opponent].games
        if games >= Self.gamesToWinSet, games - opponentGames >= Self.setMargin {
            finishSet(winner: team, tieBreak: nil)
        } else if games == Self.gamesToWinSet, opponentGames == Self.gamesToWinSet {
            phase = .tieBreak
        }
    }

    /// Fecha o set. Em set único, fechar o set encerra a partida.
    private mutating func finishSet(winner team: Team, tieBreak: TieBreakScore?) {
        sets.append(SetScore(us: scores.us.games, them: scores.them.games, tieBreak: tieBreak))
        winner = team
        phase = .finished
    }
}
