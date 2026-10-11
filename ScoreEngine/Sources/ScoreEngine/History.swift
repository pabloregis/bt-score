import Foundation

/// As partidas terminadas, da mais recente para a mais antiga, até um limite.
public struct History: Hashable, Sendable, Codable {
    /// Quantas partidas o histórico guarda; as mais antigas saem.
    public static let limit = 100

    public private(set) var records: [MatchRecord] = []

    public init() {}

    /// Acrescenta a partida. Se ela já está no histórico (mesmo início), o registro é substituído.
    public mutating func add(_ record: MatchRecord) {
        remove(startedAt: record.startedAt)
        records.append(record)
        records.sort { $0.startedAt > $1.startedAt }
        if records.count > Self.limit { records.removeLast(records.count - Self.limit) }
    }

    /// Tira a partida que começou em `startedAt`, como quando o último ponto é desfeito no resultado.
    public mutating func remove(startedAt: Date) {
        records.removeAll { $0.startedAt == startedAt }
    }
}
