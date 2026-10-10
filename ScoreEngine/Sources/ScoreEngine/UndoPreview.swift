/// O que a confirmação de desfazer mostra: quem marcou o último ponto e o placar antes e depois.
public struct UndoPreview: Hashable, Sendable {
    /// Dupla que marcou o ponto a ser desfeito.
    public let team: Team
    /// Placar atual, com o ponto.
    public let before: String
    /// Placar depois de desfazer.
    public let after: String
    /// O placar é a contagem do tie-break, e não pontos de game ou games.
    public let isTieBreak: Bool

    public init(team: Team, before: String, after: String, isTieBreak: Bool = false) {
        self.team = team
        self.before = before
        self.after = after
        self.isTieBreak = isTieBreak
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
        if before.gamesLine != after.gamesLine {
            return UndoPreview(team: team, before: before.gamesLine, after: after.gamesLine)
        }
        return UndoPreview(team: team, before: before.pointsLine, after: after.pointsLine, isTieBreak: before.phase == .tieBreak)
    }
}
