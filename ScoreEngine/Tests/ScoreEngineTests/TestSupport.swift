import ScoreEngine

let us = Team.us
let them = Team.them

/// Partida com os pontos dados. As escolhas de sacador que aparecerem no caminho são respondidas
/// com `opening` (quem abre o set) e `firstServer` (quem saca primeiro pela outra dupla).
func match(
    _ points: [Team],
    format: MatchFormat = .singleSet,
    opening: Player = .me,
    firstServer: Player = .opponent1
) -> Match {
    var match = Match(format: format)
    for team in points {
        answerServerChoice(&match, opening: opening, firstServer: firstServer)
        match.record(.point(team))
    }
    return match
}

/// Responde a escolha de sacador pendente, se houver.
func answerServerChoice(_ match: inout Match, opening: Player = .me, firstServer: Player = .opponent1) {
    switch match.state.awaitingServerChoice {
    case .openingServer: match.record(.openingServer(opening))
    case .firstServer: match.record(.firstServer(firstServer))
    case nil: break
    }
}

/// Os 4 pontos seguidos que dão um game à dupla.
func game(_ team: Team) -> [Team] {
    Array(repeating: team, count: 4)
}

/// Games em sequência, na ordem dada.
func games(_ teams: Team...) -> [Team] {
    teams.flatMap(game)
}

/// Games alternados até 6-6.
let sixAll = games(us, them, us, them, us, them, us, them, us, them, us, them)
