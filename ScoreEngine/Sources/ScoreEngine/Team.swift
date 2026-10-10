/// Uma das duas duplas da partida, do ponto de vista de quem usa o relógio.
public enum Team: Hashable, Sendable, Codable, CaseIterable {
    case us
    case them

    /// A outra dupla.
    public var opponent: Team {
        switch self {
        case .us: .them
        case .them: .us
        }
    }
}
