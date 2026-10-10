import Foundation

/// Uma partida: o formato mais o log ordenado de eventos.
/// O estado é sempre derivado reaplicando o log.
public struct Match: Hashable, Sendable, Codable {
    public let format: MatchFormat
    public private(set) var events: [MatchEvent] = []
    /// Horário do primeiro ponto; a duração conta a partir dele.
    public private(set) var startedAt: Date?

    public init(format: MatchFormat = .singleSet) {
        self.format = format
    }

    public mutating func record(_ event: MatchEvent, at date: Date = .now) {
        if events.isEmpty { startedAt = date }
        events.append(event)
    }

    /// Remove o último evento do log. Com o log vazio, não faz nada.
    /// Ao esvaziar o log, a partida volta a não ter início.
    public mutating func undo() {
        _ = events.popLast()
        if events.isEmpty { startedAt = nil }
    }

    public var state: MatchState {
        events.reduce(into: MatchState(format: format)) { $0.apply($1) }
    }
}
