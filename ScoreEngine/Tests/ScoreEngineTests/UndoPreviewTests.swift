import Testing
import ScoreEngine

@Suite("Prévia do desfazer")
struct UndoPreviewTests {
    @Test("dentro do game mostra a dupla do último ponto e os pontos antes e depois")
    func withinGame() {
        let preview = match([us, them, us]).undoPreview
        #expect(preview == UndoPreview(team: us, before: "30-15", after: "15-15"))
    }

    @Test("quando o ponto fechou um game mostra os games antes e depois")
    func gamePoint() {
        let preview = match(games(us, us) + [them, them, them, them]).undoPreview
        #expect(preview == UndoPreview(team: them, before: "2-1", after: "2-0"))
    }

    @Test("no tie-break mostra a contagem numérica")
    func tieBreak() {
        let preview = match(sixAll + [us, them, us]).undoPreview
        #expect(preview == UndoPreview(team: us, before: "2-1", after: "1-1", isTieBreak: true))
    }

    @Test("o ponto que fechou o tie-break mostra o set voltando a 6-6")
    func tieBreakPoint() {
        let preview = match(sixAll + Array(repeating: them, count: 7)).undoPreview
        #expect(preview == UndoPreview(team: them, before: "6-7", after: "6-6"))
    }

    @Test("com o log vazio não há prévia")
    func emptyLog() {
        #expect(Match().undoPreview == nil)
    }

    @Test("o ponto que fechou o set fora do tie-break mostra os games")
    func setPoint() {
        let preview = match(games(us, us, us, them, us, them, us, them) + game(us)).undoPreview
        #expect(preview == UndoPreview(team: us, before: "6-3", after: "5-3"))
    }
}
