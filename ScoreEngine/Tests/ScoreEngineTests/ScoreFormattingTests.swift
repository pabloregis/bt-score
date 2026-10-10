import Testing
import ScoreEngine

@Suite("Formatação do placar")
struct ScoreFormattingTests {
    @Test("set sem tie-break mostra só os games", arguments: [
        (SetScore(us: 6, them: 4), "6-4"),
        (SetScore(us: 5, them: 7), "5-7"),
    ])
    func plainSet(set: SetScore, expected: String) {
        #expect(set.formatted == expected)
    }

    @Test("set decidido no tie-break mostra o tie-break entre parênteses", arguments: [
        (SetScore(us: 7, them: 6, tieBreak: TieBreakScore(us: 10, them: 9)), "7-6 (10-9)"),
        (SetScore(us: 6, them: 7, tieBreak: TieBreakScore(us: 9, them: 10)), "6-7 (9-10)"),
    ])
    func tieBreakSet(set: SetScore, expected: String) {
        #expect(set.formatted == expected)
    }
}
