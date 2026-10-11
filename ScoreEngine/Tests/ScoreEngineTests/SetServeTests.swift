import Testing
import ScoreEngine

@Suite("Saque a cada set")
struct SetServeTests {
    @Test("no primeiro set, Eu vem pré-selecionado")
    func firstSetSuggestion() {
        #expect(Match(format: .bestOfThree).state.suggestedOpeningServer == .me)
    }

    @Test("cada novo set pergunta de novo quem abre")
    func asksEachSet() {
        let state = match(games(us, us, us, us, us, us), format: .bestOfThree).state
        #expect(state.awaitingServerChoice == .openingServer)
        #expect(state.server == nil)
    }

    @Test("sem tie-break, a dupla que recebeu o último game vem pré-selecionada")
    func suggestionAfterRegularSet() {
        // Eu abre: os games pares são de Nós. Em 6-0 o último game (6º) foi sacado por Eles.
        let sixLove = match(games(us, us, us, us, us, us), format: .bestOfThree).state
        #expect(sixLove.suggestedOpeningServer == .me)
        // Em 6-1 o último game (7º) foi sacado por Nós: Eles recebeu.
        let sixOne = match(games(them, us, us, us, us, us, us), format: .bestOfThree).state
        #expect(sixOne.suggestedOpeningServer == .opponent1)
    }

    @Test("depois de um tie-break, a dupla que recebeu o primeiro ponto dele vem pré-selecionada")
    func suggestionAfterTieBreak() {
        let tieBreakSet = sixAll + Array(repeating: us, count: 7)
        // Eu abre: o primeiro ponto do tie-break (turno 12) é de Nós, então Eles recebeu.
        #expect(match(tieBreakSet, format: .bestOfThree, opening: .me).state.suggestedOpeningServer == .opponent1)
        // Adversário 1 abre: o primeiro ponto é de Eles, então Nós recebeu.
        #expect(match(tieBreakSet, format: .bestOfThree, opening: .opponent1, firstServer: .me).state.suggestedOpeningServer == .me)
    }

    @Test("o match tie-break também pergunta quem abre e segue o 1-2-2")
    func matchTieBreakServe() {
        let sixLove = { (team: Team) in games(team, team, team, team, team, team) }
        var played = match(sixLove(us) + sixLove(them), format: .bestOfThree)
        #expect(played.state.awaitingServerChoice == .openingServer)
        played.record(.openingServer(.partner))
        played.record(.point(us))
        answerServerChoice(&played, firstServer: .opponent2)
        #expect(played.state.server == .opponent2)
        #expect(played.state.servePairPosition == 1)
    }

    @Test("o resumo da retomada indica o match tie-break")
    func resumeSummaryMatchTieBreak() {
        let sixLove = { (team: Team) in games(team, team, team, team, team, team) }
        let state = match(sixLove(us) + sixLove(them) + [us, us, them], format: .bestOfThree).state
        #expect(state.resumeSummary == "Set 3 · match tie-break 2-1")
    }
}
