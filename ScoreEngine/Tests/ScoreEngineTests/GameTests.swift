import Testing
import ScoreEngine

@Suite("Game no-ad")
struct GameTests {
    @Test("partida nova começa em 0-0, sem games")
    func newMatch() {
        let state = Match().state
        #expect(state.gameScore(for: us) == .love)
        #expect(state.gameScore(for: them) == .love)
        #expect(state.games(for: us) == 0)
        #expect(state.games(for: them) == 0)
    }

    @Test("pontos seguem 0, 15, 30, 40")
    func progression() {
        #expect(match([us]).state.gameScore(for: us) == .fifteen)
        #expect(match([us, us]).state.gameScore(for: us) == .thirty)
        #expect(match([us, us, us]).state.gameScore(for: us) == .forty)
        #expect(match([us, us, us]).state.gameScore(for: them) == .love)
    }

    @Test("quarto ponto seguido fecha o game e zera os pontos")
    func winGame() {
        let state = match([us, us, us, us]).state
        #expect(state.games(for: us) == 1)
        #expect(state.games(for: them) == 0)
        #expect(state.gameScore(for: us) == .love)
        #expect(state.gameScore(for: them) == .love)
    }

    @Test("no 40-40, o ponto seguinte decide o game", arguments: [Team.us, Team.them])
    func decidingPoint(winner: Team) {
        let loser = winner.opponent
        let state = match([us, us, us, them, them, them, winner]).state
        #expect(state.games(for: winner) == 1)
        #expect(state.games(for: loser) == 0)
        #expect(state.gameScore(for: us) == .love)
        #expect(state.gameScore(for: them) == .love)
    }

    @Test("games acumulam e o game em andamento continua do zero")
    func gamesAccumulate() {
        let state = match([us, us, us, us, them, them, them, them, us, us, us, us, them, them]).state
        #expect(state.games(for: us) == 2)
        #expect(state.games(for: them) == 1)
        #expect(state.gameScore(for: us) == .love)
        #expect(state.gameScore(for: them) == .thirty)
    }

    @Test("a outra dupla de Nós é Eles, e vice-versa")
    func opponent() {
        #expect(us.opponent == them)
        #expect(them.opponent == us)
    }

    @Test("partida nova usa o formato set único, e o formato é preservado")
    func format() {
        #expect(Match().format == .singleSet)
        var match = Match(format: .singleSet)
        match.record(.point(us))
        #expect(match.format == .singleSet)
    }

    @Test("o log guarda os eventos na ordem em que foram registrados")
    func eventLog() {
        #expect(match([us, them, us]).events == [.openingServer(.me), .point(us), .point(them), .point(us)])
    }
}
