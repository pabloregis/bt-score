import Foundation
import ScoreEngine

/// Guarda a partida em andamento em JSON, para retomá-la se o app fechar ou o relógio reiniciar.
struct MatchStore {
    private let file: JSONFile<Match>

    init(directory: URL = .applicationSupportDirectory) {
        file = JSONFile(name: "partida-em-andamento.json", directory: directory)
    }

    /// A partida salva, ou `nil` se não houver uma em andamento ou o arquivo não puder ser lido.
    func load() -> Match? {
        file.load()
    }

    /// Grava a partida enquanto ela está em andamento; sem pontos ou encerrada, apaga a gravação.
    func update(_ match: Match) {
        guard match.startedAt != nil, !match.state.isOver else {
            clear()
            return
        }
        file.save(match)
    }

    func clear() {
        file.clear()
    }
}
