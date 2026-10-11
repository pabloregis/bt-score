import Foundation
import Testing
import ScoreEngine

@Suite("Histórico")
struct HistoryTests {
    private let start = Date(timeIntervalSince1970: 1_760_000_000)

    /// Partida de set único terminada em 6-0 para a dupla, começando em `start`.
    private func finished(_ team: Team, at start: Date) -> Match {
        var played = Match()
        played.record(.openingServer(.me))
        played.record(.point(team), at: start)
        for point in Array(games(team, team, team, team, team, team).dropFirst()) {
            answerServerChoice(&played)
            played.record(.point(point))
        }
        return played
    }

    @Test("uma partida terminada vira registro com início, duração, sets, vencedor e placar")
    func recordFromFinishedMatch() throws {
        let record = try #require(MatchRecord(match: finished(us, at: start), finishedAt: start.addingTimeInterval(52 * 60)))
        #expect(record.startedAt == start)
        #expect(record.duration == 52 * 60)
        #expect(record.sets == [SetScore(us: 6, them: 0)])
        #expect(record.winner == us)
        #expect(record.resultLine == "6-0")
    }

    @Test("uma partida em andamento ou sem pontos não vira registro")
    func noRecordUnlessFinished() {
        #expect(MatchRecord(match: match([us, us]), finishedAt: start) == nil)
        #expect(MatchRecord(match: Match(), finishedAt: start) == nil)
    }

    private func record(_ team: Team, startingAfter minutes: Double) -> MatchRecord {
        let at = start.addingTimeInterval(minutes * 60)
        return MatchRecord(match: finished(team, at: at), finishedAt: at.addingTimeInterval(1_800))!
    }

    @Test("o histórico lista da partida mais recente para a mais antiga")
    func newestFirst() {
        var history = History()
        history.add(record(us, startingAfter: 0))
        history.add(record(them, startingAfter: 120))
        history.add(record(us, startingAfter: 60))
        #expect(history.records.map(\.startedAt) == [120, 60, 0].map { start.addingTimeInterval($0 * 60) })
    }

    @Test("adicionar a mesma partida de novo substitui o registro em vez de duplicar")
    func addReplacesSameMatch() {
        var history = History()
        history.add(record(us, startingAfter: 0))
        history.add(record(us, startingAfter: 0))
        #expect(history.records.count == 1)
    }

    @Test("desfazer a partir do resultado tira a partida do histórico")
    func removeUndoneMatch() {
        var history = History()
        history.add(record(us, startingAfter: 0))
        history.add(record(them, startingAfter: 60))
        history.remove(startedAt: start)
        #expect(history.records.map(\.winner) == [them])
    }

    @Test("o histórico guarda só as últimas 100 partidas")
    func keepsLastHundred() {
        var history = History()
        for minutes in 0..<101 { history.add(record(us, startingAfter: Double(minutes))) }
        #expect(history.records.count == 100)
        #expect(history.records.last?.startedAt == start.addingTimeInterval(60))
    }

    @Test("salvar e carregar o histórico reproduz os registros, inclusive com match tie-break")
    func roundTrip() throws {
        var history = History()
        history.add(record(us, startingAfter: 0))
        let sixLove = { (team: Team) in games(team, team, team, team, team, team) }
        var bestOfThree = match(sixLove(us) + sixLove(them) + Array(repeating: them, count: 10), format: .bestOfThree)
        answerServerChoice(&bestOfThree)
        history.add(try #require(MatchRecord(match: bestOfThree, finishedAt: .now)))
        let loaded = try JSONDecoder().decode(History.self, from: JSONEncoder().encode(history))
        #expect(loaded == history)
        #expect(loaded.records.contains { $0.resultLine == "6-0 0-6 [0-10]" })
    }
}
