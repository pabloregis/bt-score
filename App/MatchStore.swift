import Foundation
import ScoreEngine

/// Guarda a partida em andamento em JSON, para retomá-la se o app fechar ou o relógio reiniciar.
struct MatchStore {
    private let url: URL

    init(directory: URL = .applicationSupportDirectory) {
        url = directory.appending(path: "partida-em-andamento.json")
    }

    /// A partida salva, ou `nil` se não houver uma em andamento ou o arquivo não puder ser lido.
    func load() -> Match? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(Match.self, from: data)
    }

    /// Grava a partida enquanto ela está em andamento; sem pontos ou encerrada, apaga a gravação.
    func update(_ match: Match) {
        guard match.startedAt != nil, !match.state.isOver else {
            clear()
            return
        }
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try JSONEncoder().encode(match).write(to: url, options: .atomic)
        } catch {
            // Sem a gravação, a partida segue normalmente; só não dá para retomá-la.
        }
    }

    func clear() {
        try? FileManager.default.removeItem(at: url)
    }
}
