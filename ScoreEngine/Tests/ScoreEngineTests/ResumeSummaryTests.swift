import Testing
import ScoreEngine

@Suite("Resumo da retomada")
struct ResumeSummaryTests {
    @Test("no game mostra o set, os games e os pontos")
    func inGame() {
        let state = match(games(us, them, us, them, us, us, them) + [us, us, them]).state
        #expect(state.resumeSummary == "Set 1 · games 4-3 · 30-15")
    }

    @Test("no tie-break indica a fase e a contagem")
    func inTieBreak() {
        let state = match(sixAll + [us, us, them, us, them]).state
        #expect(state.resumeSummary == "Set 1 · games 6-6 · tie-break 3-2")
    }
}
