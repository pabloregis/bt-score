/// Uma partida: o formato mais o log ordenado de eventos.
/// O estado é sempre derivado reaplicando o log.
public struct Match: Hashable, Sendable {
    public let format: MatchFormat
    public private(set) var events: [MatchEvent] = []

    public init(format: MatchFormat = .singleSet) {
        self.format = format
    }

    public mutating func record(_ event: MatchEvent) {
        events.append(event)
    }

    public var state: MatchState {
        events.reduce(into: MatchState(format: format)) { $0.apply($1) }
    }
}
