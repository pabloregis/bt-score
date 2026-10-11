import Testing
import ScoreEngine

@Suite("Rodízio de saque")
struct ServeTests {
    @Test("partida nova aguarda o sacador que abre o set, e pontos não são aceitos")
    func awaitsOpeningServer() {
        var played = Match()
        #expect(played.state.awaitingServerChoice == .openingServer)
        #expect(played.state.server == nil)
        played.record(.point(us))
        #expect(played.events.isEmpty)
    }

    @Test("quem abre o set saca o primeiro game")
    func openingServerServesFirstGame() {
        var played = Match()
        played.record(.openingServer(.partner))
        #expect(played.state.awaitingServerChoice == nil)
        #expect(played.state.server == .partner)
    }

    @Test("depois do primeiro game, pergunta quem saca primeiro pela outra dupla")
    func asksOpponentFirstServer() {
        var played = Match()
        played.record(.openingServer(.me))
        for _ in 0..<4 { played.record(.point(us)) }
        #expect(played.state.awaitingServerChoice == .firstServer(of: them))
        #expect(played.state.server == nil)
        played.record(.point(them))
        played.record(.firstServer(.me))
        #expect(played.events.count == 5)
        played.record(.firstServer(.opponent2))
        #expect(played.state.server == .opponent2)
    }

    /// Sacador depois dos pontos dados, com Eu abrindo o set e Adversário 1 sacando primeiro por Eles.
    private func server(after points: [Team]) -> Player? {
        var played = match(points)
        answerServerChoice(&played)
        return played.state.server
    }

    @Test("o saque alterna entre as duplas a cada game e, dentro delas, entre os jogadores")
    func alternatesEachGame() {
        let servers = (0...4).map { server(after: Array(games(us, them, us, them, us).prefix($0 * 4))) }
        #expect(servers == [.me, .opponent1, .partner, .opponent2, .me])
    }

    @Test("no meio do game o sacador não muda")
    func sameServerWithinGame() {
        #expect(server(after: [us, them, us]) == .me)
    }

    @Test("no tie-break, o próximo sacador saca 1 ponto e depois cada um saca 2 seguidos")
    func tieBreakOneTwoTwo() {
        let servers = (0...6).map { server(after: sixAll + Array(repeating: us, count: $0)) }
        #expect(servers == [.me, .opponent1, .opponent1, .partner, .partner, .opponent2, .opponent2])
    }

    @Test("no tie-break indica a posição dentro do par; o ponto sozinho e o game normal não têm")
    func pairPosition() {
        let positions = (0...4).map { match(sixAll + Array(repeating: us, count: $0)).state.servePairPosition }
        #expect(positions == [nil, 1, 2, 1, 2])
        #expect(match([us, them]).state.servePairPosition == nil)
    }

    @Test("desfazer a escolha da outra dupla volta a aguardá-la; desfazer o ponto antes dela volta ao game")
    func undoFirstServer() {
        var played = match(game(us))
        played.record(.firstServer(.opponent2))
        played.undo()
        #expect(played.state.awaitingServerChoice == .firstServer(of: them))
        played.undo()
        #expect(played.state.awaitingServerChoice == nil)
        #expect(played.state.server == .me)
        #expect(played.state.gameScore(for: us) == .forty)
    }

    @Test("desfazer a escolha de quem abre volta a aguardá-la")
    func undoOpeningServer() {
        var played = Match()
        played.record(.openingServer(.opponent1))
        played.undo()
        #expect(played.state.awaitingServerChoice == .openingServer)
        #expect(played.events.isEmpty)
    }

    @Test("com uma escolha como último evento não há prévia de desfazer: ela volta direto")
    func noPreviewForChoice() {
        var played = match(game(us))
        played.record(.firstServer(.opponent1))
        #expect(played.undoPreview == nil)
        #expect(played.lastEventIsServerChoice)
        #expect(!match([us]).lastEventIsServerChoice)
    }

    @Test("cada escolha vira o evento certo para o jogador escolhido")
    func choiceEvent() {
        #expect(ServerChoice.openingServer.event(for: .partner) == .openingServer(.partner))
        #expect(ServerChoice.firstServer(of: them).event(for: .opponent2) == .firstServer(.opponent2))
    }
}
