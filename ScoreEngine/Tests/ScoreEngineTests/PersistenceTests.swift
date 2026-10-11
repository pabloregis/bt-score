import Foundation
import Testing
import ScoreEngine

@Suite("Persistência")
struct PersistenceTests {
    private func roundTrip(_ match: Match) throws -> Match {
        try JSONDecoder().decode(Match.self, from: JSONEncoder().encode(match))
    }

    @Test("salvar e carregar uma partida no tie-break reproduz o mesmo estado")
    func roundTripTieBreak() throws {
        let saved = match(sixAll + [us, them, us])
        let loaded = try roundTrip(saved)
        #expect(loaded == saved)
        #expect(loaded.state == saved.state)
        #expect(loaded.state.tieBreakPoints(for: us) == 2)
    }

    @Test("o horário de início sobrevive a salvar e carregar")
    func roundTripStart() throws {
        var saved = Match()
        saved.record(.point(us), at: Date(timeIntervalSince1970: 1_760_000_000))
        #expect(try roundTrip(saved).startedAt == saved.startedAt)
    }
}
