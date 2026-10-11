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
        saved.record(.openingServer(.me))
        saved.record(.point(us), at: Date(timeIntervalSince1970: 1_760_000_000))
        #expect(try roundTrip(saved).startedAt == saved.startedAt)
    }

    @Test("uma partida salva sem a escolha de sacador não carrega")
    func rejectsLogWithoutServerChoice() {
        let legacy = #"{"format":{"setTieBreak":{"target":7,"margin":2,"cap":10}},"events":[{"point":{"_0":{"us":{}}}}]}"#
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(Match.self, from: Data(legacy.utf8))
        }
    }

    @Test("uma partida de set único salva antes do melhor de 3 continua carregando")
    func legacySingleSetFormat() throws {
        let legacy = #"{"setTieBreak":{"target":7,"margin":2,"cap":10}}"#
        #expect(try JSONDecoder().decode(MatchFormat.self, from: Data(legacy.utf8)) == .singleSet)
    }

    @Test("o formato melhor de 3 sobrevive a salvar e carregar")
    func roundTripBestOfThree() throws {
        let saved = match(games(us, us, us, us, us, us), format: .bestOfThree)
        let loaded = try roundTrip(saved)
        #expect(loaded.format == .bestOfThree)
        #expect(loaded.state == saved.state)
    }
}
