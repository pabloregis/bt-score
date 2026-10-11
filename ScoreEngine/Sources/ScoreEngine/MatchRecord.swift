import Foundation

/// Uma partida terminada no histórico: quando começou, quanto durou e o placar por set.
/// O log de pontos não é guardado.
public struct MatchRecord: Hashable, Sendable, Codable {
    /// Horário do primeiro ponto; também identifica a partida no histórico.
    public let startedAt: Date
    /// Do primeiro ponto ao último, em segundos.
    public let duration: TimeInterval
    public let sets: [SetScore]
    public let winner: Team

    /// Registro de uma partida terminada, ou `nil` se ela não terminou.
    public init?(match: Match, finishedAt: Date) {
        let state = match.state
        guard let startedAt = match.startedAt, let winner = state.winner else { return nil }
        self.startedAt = startedAt
        duration = finishedAt.timeIntervalSince(startedAt)
        sets = state.sets
        self.winner = winner
    }

    /// Os sets em sequência, do ponto de vista de Nós: "6-3 4-6 [10-7]".
    public var resultLine: String {
        sets.resultLine
    }
}

extension [SetScore] {
    /// Os sets em sequência, do ponto de vista de Nós: "6-3 4-6 [10-7]".
    var resultLine: String {
        map(\.formatted).joined(separator: " ")
    }
}
