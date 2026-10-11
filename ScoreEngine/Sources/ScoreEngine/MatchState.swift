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
    /// O que o último evento gerou, se ele foi um ponto; `nil` sem pontos ou depois de uma escolha de sacador.
    public private(set) var lastPointOutcome: PointOutcome?

    /// Primeiro sacador de cada dupla no set; a dupla de quem abre o set entra na escolha inicial.
    private var firstServers: [Team: Player] = [:]
    /// Dupla que abriu o set.
    private var openingTeam: Team?

    public var isOver: Bool { phase == .finished }

    /// A escolha de sacador que a partida aguarda; enquanto houver uma, pontos não são aceitos.
    public var awaitingServerChoice: ServerChoice? {
        guard !isOver else { return nil }
        guard let openingTeam else { return .openingServer }
        let team = servingTeam(turn: serveTurn, openingTeam: openingTeam)
        return firstServers[team] == nil ? .firstServer(of: team) : nil
    }

    /// Quem saca o ponto atual, ou `nil` enquanto aguarda uma escolha ou depois do fim.
    public var server: Player? {
        guard !isOver, let openingTeam else { return nil }
        let turn = serveTurn
        let team = servingTeam(turn: turn, openingTeam: openingTeam)
        guard let first = firstServers[team] else { return nil }
        // Cada dupla saca nos turnos alternados; dentro dela, os dois jogadores se revezam.
        return (turn / 2).isMultiple(of: 2) ? first : first.teammate
    }

    /// No tie-break, qual dos 2 pontos seguidos do sacador é o atual (1 ou 2).
    /// `nil` no game normal e no primeiro ponto do tie-break, que é sacado sozinho.
    public var servePairPosition: Int? {
        guard phase == .tieBreak else { return nil }
        let points = scores.us.tieBreakPoints + scores.them.tieBreakPoints
        guard points > 0 else { return nil }
        return points.isMultiple(of: 2) ? 2 : 1
    }

    /// Turno de saque desde o início do set: um por game e, no tie-break, o primeiro ponto
    /// sozinho e depois um turno a cada 2 pontos, seguindo o rodízio.
    private var serveTurn: Int {
        let games = scores.us.games + scores.them.games
        guard phase == .tieBreak else { return games }
        let points = scores.us.tieBreakPoints + scores.them.tieBreakPoints
        return games + (points + 1) / 2
    }

    private func servingTeam(turn: Int, openingTeam: Team) -> Team {
        turn.isMultiple(of: 2) ? openingTeam : openingTeam.opponent
    }

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

    /// Onde a partida parou, para a tela de retomada: "Set 1 · games 4-3 · 30-15".
    public var resumeSummary: String {
        let points = phase == .tieBreak ? "tie-break \(pointsLine)" : pointsLine
        return "Set \(sets.count + 1) · games \(gamesLine) · \(points)"
    }

    /// Se o evento vale no estado atual: pontos só sem escolha pendente, escolhas só quando
    /// são a aguardada, e nada depois do fim.
    func accepts(_ event: MatchEvent) -> Bool {
        switch event {
        case .point: awaitingServerChoice == nil && !isOver
        case .openingServer: awaitingServerChoice == .openingServer
        case .firstServer(let player): awaitingServerChoice == .firstServer(of: player.team)
        }
    }

    mutating func apply(_ event: MatchEvent) {
        guard accepts(event) else { return }
        switch event {
        case .openingServer(let player):
            lastPointOutcome = nil
            openingTeam = player.team
            firstServers[player.team] = player
        case .firstServer(let player):
            lastPointOutcome = nil
            firstServers[player.team] = player
        case .point(let team):
            lastPointOutcome = .point
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
        lastPointOutcome = .game
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
        // Em set único, fechar o set sempre encerra a partida; `.set` entra com o melhor de 3 (PAB-14).
        lastPointOutcome = .match
    }
}
