/// O que a confirmação de desfazer mostra: quem marcou o último ponto e o placar antes e depois.
public struct UndoPreview: Hashable, Sendable {
    /// Dupla que marcou o ponto a ser desfeito.
    public let team: Team
    /// Placar atual, com o ponto.
    public let before: String
    /// Placar depois de desfazer.
    public let after: String

    public init(team: Team, before: String, after: String) {
        self.team = team
        self.before = before
        self.after = after
    }
}

extension Match {
    /// Prévia do desfazer, ou `nil` com o log vazio.
    public var undoPreview: UndoPreview? {
        guard case .point(let team)? = events.last else { return nil }
        var undone = self
        undone.undo()
        let before = state
        let after = undone.state
        // Quando o ponto fechou um game, os pontos zeram; os games mostram melhor o que muda.
        if before.gamesFormatted != after.gamesFormatted {
            return UndoPreview(team: team, before: before.gamesFormatted, after: after.gamesFormatted)
        }
        return UndoPreview(team: team, before: before.pointsFormatted, after: after.pointsFormatted)
    }
}
