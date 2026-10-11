import Foundation
import Testing
import ScoreEngine

@Suite("Horário de início")
struct StartTimeTests {
    private let first = Date(timeIntervalSince1970: 1_000)
    private let later = Date(timeIntervalSince1970: 2_000)

    @Test("o início é o horário do primeiro ponto; os seguintes não o mudam")
    func startsAtFirstPoint() {
        var played = Match()
        played.record(.openingServer(.me), at: Date(timeIntervalSince1970: 500))
        #expect(played.startedAt == nil)
        played.record(.point(us), at: first)
        played.record(.point(them), at: later)
        #expect(played.startedAt == first)
    }

    @Test("desfazer mantém o início; desfazer até o log vazio o limpa, e o próximo ponto recomeça")
    func undoClearsStart() {
        var played = Match()
        played.record(.openingServer(.me), at: first)
        played.record(.point(us), at: first)
        played.record(.point(us), at: first)
        played.undo()
        #expect(played.startedAt == first)
        played.undo()
        #expect(played.startedAt == nil)
        played.record(.point(them), at: later)
        #expect(played.startedAt == later)
    }
}
