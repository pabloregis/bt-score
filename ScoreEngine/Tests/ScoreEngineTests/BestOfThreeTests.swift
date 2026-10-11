import Testing
import ScoreEngine

@Suite("Melhor de 3")
struct BestOfThreeTests {
    /// Um set de 6-0 para a dupla.
    private func set(_ team: Team) -> [Team] {
        Array(repeating: game(team), count: 6).flatMap { $0 }
    }

    @Test("o formato melhor de 3 pede 2 sets e tem match tie-break a 10, vantagem 2, sem teto")
    func format() {
        #expect(MatchFormat.bestOfThree.setsToWin == 2)
        #expect(MatchFormat.bestOfThree.matchTieBreak == TieBreakRule(target: 10, margin: 2, cap: nil))
        #expect(MatchFormat.singleSet.setsToWin == 1)
    }

    @Test("fechar o primeiro set não encerra a partida: o placar zera e o set conta")
    func firstSetContinues() {
        let state = match(set(us), format: .bestOfThree).state
        #expect(!state.isOver)
        #expect(state.lastPointOutcome == .set)
        #expect(state.sets == [SetScore(us: 6, them: 0)])
        #expect(state.setsWon(for: us) == 1)
        #expect(state.games(for: us) == 0)
        #expect(state.phase == .game)
    }

    @Test("2-0 em sets encerra a partida")
    func twoNil() {
        let state = match(set(them) + set(them), format: .bestOfThree).state
        #expect(state.winner == them)
        #expect(state.lastPointOutcome == .match)
        #expect(state.setsWon(for: them) == 2)
    }

    /// Match tie-break empatado ponto a ponto até `n`-`n`.
    private func tieBreakAll(_ n: Int) -> [Team] {
        Array(repeating: [us, them], count: n).flatMap { $0 }
    }

    @Test("no 1-1 o terceiro set é um match tie-break, contado em pontos")
    func oneAllMatchTieBreak() {
        let state = match(set(us) + set(them) + [us, us, them], format: .bestOfThree).state
        #expect(state.phase == .matchTieBreak)
        #expect(state.tieBreakPoints(for: us) == 2)
        #expect(state.pointsFormatted(for: them) == "1")
        #expect(!state.isOver)
    }

    @Test("o match tie-break não tem teto: 10-10 continua e fecha em 12-10")
    func matchTieBreakPastTen() {
        let base = set(us) + set(them) + tieBreakAll(10)
        let elevenTen = match(base + [them], format: .bestOfThree).state
        #expect(!elevenTen.isOver)
        let state = match(base + [them, them], format: .bestOfThree).state
        #expect(state.winner == them)
        #expect(state.lastPointOutcome == .match)
        #expect(state.sets.last == SetScore(us: 10, them: 12, isMatchTieBreak: true))
    }

    @Test("o resultado lista os sets em sequência, com tie-break entre parênteses e match tie-break entre colchetes")
    func resultLine() {
        let tieBreakSet = Array(repeating: [us, them], count: 6).flatMap { game($0[0]) + game($0[1]) }
            + Array(repeating: them, count: 7)
        let points = set(us) + tieBreakSet + Array(repeating: us, count: 10)
        let state = match(points, format: .bestOfThree).state
        #expect(state.resultLine == "6-0 6-7 (0-7) [10-0]")
    }
}
