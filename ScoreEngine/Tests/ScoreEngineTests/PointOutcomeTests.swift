import Testing
import ScoreEngine

@Suite("Evento do último ponto")
struct PointOutcomeTests {
    @Test("um ponto dentro do game é ponto comum")
    func plainPoint() {
        #expect(match([us]).state.lastPointOutcome == .point)
    }

    @Test("o ponto que fecha um game é fim de game")
    func gamePoint() {
        #expect(match(game(us)).state.lastPointOutcome == .game)
    }

    @Test("em set único, o ponto que fecha o set encerra a partida")
    func matchPoint() {
        #expect(match(games(us, us, us, us, us, us)).state.lastPointOutcome == .match)
    }

    @Test("o ponto que fecha o tie-break encerra a partida; os anteriores são ponto comum")
    func tieBreakPoints() {
        #expect(match(sixAll).state.lastPointOutcome == .game)
        #expect(match(sixAll + [us]).state.lastPointOutcome == .point)
        #expect(match(sixAll + Array(repeating: them, count: 7)).state.lastPointOutcome == .match)
    }

    @Test("sem pontos ou depois de uma escolha de sacador não há evento")
    func noOutcome() {
        #expect(Match().state.lastPointOutcome == nil)
        var played = match(game(us))
        played.record(.firstServer(.opponent1))
        #expect(played.state.lastPointOutcome == nil)
    }
}
