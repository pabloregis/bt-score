import Foundation

/// Uma partida: o formato mais o log ordenado de eventos.
/// O estado é sempre derivado reaplicando o log.
public struct Match: Hashable, Sendable, Codable {
    public let format: MatchFormat
    public private(set) var events: [MatchEvent] = []
    /// Horário do primeiro ponto (não da escolha de sacador); a duração conta a partir dele.
    public private(set) var startedAt: Date?

    public init(format: MatchFormat = .singleSet) {
        self.format = format
    }

    /// Registra o evento no log. Um evento que não vale no estado atual (ponto com escolha
    /// de sacador pendente, escolha fora de hora, qualquer coisa depois do fim) é ignorado.
    public mutating func record(_ event: MatchEvent, at date: Date = .now) {
        guard state.accepts(event) else { return }
        if case .point = event, !hasPoints { startedAt = date }
        events.append(event)
    }

    private var hasPoints: Bool {
        events.contains { if case .point = $0 { true } else { false } }
    }

    /// Remove o último evento do log. Com o log vazio, não faz nada.
    /// Sem nenhum ponto no log, a partida volta a não ter início.
    public mutating func undo() {
        _ = events.popLast()
        if !hasPoints { startedAt = nil }
    }

    /// O último evento é uma escolha de sacador; desfazê-lo só volta à escolha, sem confirmação.
    public var lastEventIsServerChoice: Bool {
        switch events.last {
        case .openingServer, .firstServer: true
        case .point, nil: false
        }
    }

    public var state: MatchState {
        events.reduce(into: MatchState(format: format)) { $0.apply($1) }
    }
}

extension Match {
    private enum CodingKeys: String, CodingKey {
        case format, events, startedAt
    }

    /// Carrega uma partida salva, recusando um log que o motor não reproduz inteiro
    /// (ex.: gravado antes do rodízio de saque, sem a escolha de quem abre o set).
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(format: try container.decode(MatchFormat.self, forKey: .format))
        let saved = try container.decode([MatchEvent].self, forKey: .events)
        var replay = MatchState(format: format)
        for event in saved {
            guard replay.accepts(event) else {
                throw DecodingError.dataCorruptedError(forKey: .events, in: container, debugDescription: "Evento que o motor não aceita: \(event)")
            }
            replay.apply(event)
        }
        events = saved
        startedAt = try container.decodeIfPresent(Date.self, forKey: .startedAt)
    }
}
