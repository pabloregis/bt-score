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
    /// Dupla sugerida para abrir o próximo set: a que recebeu o primeiro ponto do tie-break
    /// ou, sem tie-break, o último game. No primeiro set, Nós.
    private var suggestedOpeningTeam: Team = .us

    public var isOver: Bool { phase == .finished }

    /// A escolha de sacador que a partida aguarda; enquanto houver uma, pontos não são aceitos.
    public var awaitingServerChoice: ServerChoice? {
        guard !isOver else { return nil }
        guard let openingTeam else { return .openingServer }
        let team = servingTeam(turn: serveTurn, openingTeam: openingTeam)
        return firstServers[team] == nil ? .firstServer(of: team) : nil
    }

    /// Quem vem pré-selecionado na escolha de quem abre o set: Eu, se a dupla sugerida é Nós,
    /// ou Adversário 1, se é Eles. `nil` fora dessa escolha.
    public var suggestedOpeningServer: Player? {
        guard awaitingServerChoice == .openingServer else { return nil }
        return suggestedOpeningTeam == .us ? .me : .opponent1
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
        guard phase.isTieBreak else { return nil }
        let points = scores.us.tieBreakPoints + scores.them.tieBreakPoints
        guard points > 0 else { return nil }
        return points.isMultiple(of: 2) ? 2 : 1
    }

    /// Turno de saque desde o início do set: um por game e, no tie-break, o primeiro ponto
    /// sozinho e depois um turno a cada 2 pontos, seguindo o rodízio.
    private var serveTurn: Int {
        let games = scores.us.games + scores.them.games
        guard phase.isTieBreak else { return games }
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

    /// Sets vencidos pela dupla.
    public func setsWon(for team: Team) -> Int {
        sets.filter { $0.winner == team }.count
    }

    public func tieBreakPoints(for team: Team) -> Int {
        scores[team].tieBreakPoints
    }

    /// Pontos da dupla como o jogador lê: 0-15-30-40 no game, a contagem no tie-break.
    public func pointsFormatted(for team: Team) -> String {
        phase.isTieBreak ? "\(tieBreakPoints(for: team))" : gameScore(for: team).formatted
    }

    /// Pontos das duas duplas, do ponto de vista de Nós: "30-15".
    var pointsLine: String {
        "\(pointsFormatted(for: .us))-\(pointsFormatted(for: .them))"
    }

    /// Games do set em andamento, do ponto de vista de Nós: "3-2".
    var gamesLine: String {
        "\(games(for: .us))-\(games(for: .them))"
    }

    /// Os sets em sequência, do ponto de vista de Nós: "6-3 4-6 [10-7]".
    public var resultLine: String {
        sets.map(\.formatted).joined(separator: " ")
    }

    /// Onde a partida parou, para a tela de retomada: "Set 1 · games 4-3 · 30-15".
    public var resumeSummary: String {
        let set = "Set \(sets.count + 1)"
        switch phase {
        case .matchTieBreak: return "\(set) · match tie-break \(pointsLine)"
        case .tieBreak: return "\(set) · games \(gamesLine) · tie-break \(pointsLine)"
        case .game, .finished: return "\(set) · games \(gamesLine) · \(pointsLine)"
        }
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
            if phase.isTieBreak {
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
        let isMatchTieBreak = phase == .matchTieBreak
        let rule = isMatchTieBreak ? format.matchTieBreak ?? format.setTieBreak : format.setTieBreak
        let won = rule.isWon(
            points: scores[team].tieBreakPoints,
            opponentPoints: scores[team.opponent].tieBreakPoints
        )
        guard won else { return }
        if isMatchTieBreak {
            let points = scores.tieBreakScore
            finishSet(winner: team, score: SetScore(us: points.us, them: points.them, isMatchTieBreak: true))
        } else {
            scores[team].games += 1
            finishSet(winner: team, score: SetScore(us: scores.us.games, them: scores.them.games, tieBreak: scores.tieBreakScore))
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
            finishSet(winner: team, score: SetScore(us: scores.us.games, them: scores.them.games))
        } else if games == Self.gamesToWinSet, opponentGames == Self.gamesToWinSet {
            phase = .tieBreak
        }
    }

    /// Fecha o set. Com os sets para vencer, a partida acaba; senão o placar zera e o próximo
    /// set começa pedindo de novo quem saca.
    private mutating func finishSet(winner team: Team, score: SetScore) {
        sets.append(score)
        if setsWon(for: team) == format.setsToWin {
            winner = team
            phase = .finished
            lastPointOutcome = .match
            return
        }
        lastPointOutcome = .set
        if let openingTeam {
            // No tie-break, o primeiro ponto é o turno logo depois dos 12 games; sem ele, o último game.
            let lastTurn = score.tieBreak != nil ? Self.gamesToWinSet * 2 : score.us + score.them - 1
            suggestedOpeningTeam = servingTeam(turn: lastTurn, openingTeam: openingTeam).opponent
        }
        scores = Scores()
        openingTeam = nil
        firstServers = [:]
        let decider = setsWon(for: .us) == format.setsToWin - 1 && setsWon(for: .them) == format.setsToWin - 1
        phase = decider && format.matchTieBreak != nil ? .matchTieBreak : .game
    }
}
