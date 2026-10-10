import ScoreEngine

let us = Team.us
let them = Team.them

func match(_ points: [Team], format: MatchFormat = .singleSet) -> Match {
    var match = Match(format: format)
    for team in points { match.record(.point(team)) }
    return match
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
