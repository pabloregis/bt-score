import Testing
import ScoreEngine

/// Games alternados até 6-6.
let sixAll = games(us, them, us, them, us, them, us, them, us, them, us, them)

@Suite("Tie-break do set")
struct TieBreakTests {
    @Test("antes do 6-6 a fase é game normal")
    func normalPhase() {
        #expect(match([]).state.phase == .game)
        #expect(match(Array(sixAll.dropLast(4))).state.phase == .game)
    }

    @Test("no 6-6 entra em tie-break e conta os pontos em números")
    func entersTieBreak() {
        let state = match(sixAll + [us, us, them]).state
        #expect(state.phase == .tieBreak)
        #expect(!state.isOver)
        #expect(state.tieBreakPoints(for: us) == 2)
        #expect(state.tieBreakPoints(for: them) == 1)
        #expect(state.games(for: us) == 6)
        #expect(state.games(for: them) == 6)
    }

    @Test("tie-break fecha em 7-5 e o set termina 7-6 com o placar do tie-break")
    func winsTieBreakSevenFive() {
        let tieBreak: [Team] = [us, them, us, them, us, them, us, them, us, them, us, us]
        let state = match(sixAll + tieBreak).state
        #expect(state.winner == us)
        #expect(state.sets == [SetScore(us: 7, them: 6, tieBreak: TieBreakScore(us: 7, them: 5))])
    }

    /// Tie-break empatado ponto a ponto até `n`-`n`.
    private func tieBreakAll(_ n: Int) -> [Team] {
        Array(repeating: [us, them], count: n).flatMap { $0 }
    }

    @Test("em 7-6 o tie-break continua; em 8-6 ele fecha")
    func needsTwoPointMargin() {
        let sevenSix = match(sixAll + tieBreakAll(6) + [them]).state
        #expect(!sevenSix.isOver)
        #expect(sevenSix.tieBreakPoints(for: them) == 7)

        let eightSix = match(sixAll + tieBreakAll(6) + [them, them]).state
        #expect(eightSix.winner == them)
        #expect(eightSix.sets == [SetScore(us: 6, them: 7, tieBreak: TieBreakScore(us: 6, them: 8))])
    }

    @Test("o formato padrão usa tie-break com alvo 7, vantagem 2 e teto 10")
    func defaultRule() {
        #expect(MatchFormat.singleSet.setTieBreak == TieBreakRule(target: 7, margin: 2, cap: 10))
    }

    @Test("com regra a 10 sem teto, 10-9 não fecha e 11-9 fecha")
    func customRule() {
        let format = MatchFormat(setTieBreak: TieBreakRule(target: 10, margin: 2, cap: nil))
        let tenNine = match(sixAll + tieBreakAll(9) + [us], format: format).state
        #expect(!tenNine.isOver)

        let elevenNine = match(sixAll + tieBreakAll(9) + [us, us], format: format).state
        #expect(elevenNine.sets == [SetScore(us: 7, them: 6, tieBreak: TieBreakScore(us: 11, them: 9))])
    }

    @Test("no 9-9 o ponto seguinte decide: o set fecha em 10-9", arguments: [Team.us, Team.them])
    func capAtTen(winner: Team) {
        let state = match(sixAll + tieBreakAll(9) + [winner]).state
        #expect(state.winner == winner)
        let expected = winner == us
            ? SetScore(us: 7, them: 6, tieBreak: TieBreakScore(us: 10, them: 9))
            : SetScore(us: 6, them: 7, tieBreak: TieBreakScore(us: 9, them: 10))
        #expect(state.sets == [expected])
    }
}
