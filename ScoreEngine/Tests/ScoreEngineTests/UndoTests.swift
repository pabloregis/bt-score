import Testing
import ScoreEngine

@Suite("Desfazer")
struct UndoTests {
    @Test("desfazer dentro do game volta o placar ao ponto anterior")
    func undoWithinGame() {
        var played = match([us, us, them])
        played.undo()
        #expect(played.events == [.point(us), .point(us)])
        #expect(played.state.gameScore(for: us) == .thirty)
        #expect(played.state.gameScore(for: them) == .love)
    }

    @Test("desfazer o ponto que fechou um game devolve o game e o 40")
    func undoGamePoint() {
        var played = match([us, us, us, them, us])
        played.undo()
        #expect(played.state.games(for: us) == 0)
        #expect(played.state.gameScore(for: us) == .forty)
        #expect(played.state.gameScore(for: them) == .fifteen)
    }

    @Test("desfazer o ponto que fechou o set reabre a partida")
    func undoSetPoint() {
        let points = games(us, us, us, us, us, us)
        var played = match(points)
        played.undo()
        #expect(played.state == match(Array(points.dropLast())).state)
        #expect(!played.state.isOver)
        #expect(played.state.winner == nil)
        #expect(played.state.sets.isEmpty)
        #expect(played.state.games(for: us) == 5)
        #expect(played.state.gameScore(for: us) == .forty)
    }

    @Test("desfazer o ponto que fechou o tie-break volta ao tie-break")
    func undoTieBreakPoint() {
        var played = match(sixAll + Array(repeating: us, count: 7))
        played.undo()
        #expect(played.state.phase == .tieBreak)
        #expect(played.state.tieBreakPoints(for: us) == 6)
        #expect(played.state.games(for: us) == 6)
        #expect(played.state.winner == nil)
    }

    @Test("desfazer o ponto que levou ao 6-6 sai do tie-break")
    func undoIntoTieBreak() {
        var played = match(sixAll)
        played.undo()
        #expect(played.state.phase == .game)
        #expect(played.state.games(for: them) == 5)
        #expect(played.state.gameScore(for: them) == .forty)
    }

    @Test("desfazer até o início deixa o log vazio, e desfazer de novo não faz nada")
    func undoToEmpty() {
        var played = match([us, them])
        played.undo()
        played.undo()
        #expect(played.events.isEmpty)
        #expect(played == Match())
        played.undo()
        #expect(played == Match())
    }
}
