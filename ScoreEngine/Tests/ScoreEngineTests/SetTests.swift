import Testing
import ScoreEngine

@Suite("Set e fim de partida")
struct SetTests {
    @Test("set termina em 6-4 e a partida acaba com vitória de Nós")
    func setSixFour() {
        let state = match(games(us, them, us, them, us, them, us, us, them, us)).state
        #expect(state.isOver)
        #expect(state.winner == us)
        #expect(state.sets == [SetScore(us: 6, them: 4)])
    }

    @Test("em 6-5 o set continua; em 7-5 ele fecha a favor de Eles")
    func setSevenFive() {
        let fiveAll = games(us, them, us, them, us, them, us, them, us, them)
        let sixFive = match(fiveAll + game(them)).state
        #expect(!sixFive.isOver)
        #expect(sixFive.games(for: them) == 6)
        #expect(sixFive.sets.isEmpty)

        let sevenFive = match(fiveAll + games(them, them)).state
        #expect(sevenFive.winner == them)
        #expect(sevenFive.sets == [SetScore(us: 5, them: 7)])
    }

    @Test("depois do fim, a fase é encerrada, inclusive quando o fim vem no tie-break")
    func finishedPhase() {
        #expect(match(games(us, us, us, us, us, us)).state.phase == .finished)
        #expect(match(sixAll + Array(repeating: us, count: 7)).state.phase == .finished)
    }

    @Test("pontos depois do fim da partida não mudam o placar")
    func pointsAfterEndIgnored() {
        let finished = games(us, us, us, us, us, us)
        let state = match(finished + game(them) + [them]).state
        #expect(state.winner == us)
        #expect(state.sets == [SetScore(us: 6, them: 0)])
        #expect(state.games(for: them) == 0)
        #expect(state.gameScore(for: them) == .love)
    }
}
