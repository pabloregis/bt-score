/// O que um ponto gerou, do menor ao maior: o app traduz em vibração.
public enum PointOutcome: Hashable, Sendable {
    /// Ponto comum, dentro do game ou do tie-break.
    case point
    /// O ponto fechou um game.
    case game
    /// O ponto fechou um set sem encerrar a partida. Só acontece com mais de um set (PAB-14).
    case set
    /// O ponto encerrou a partida.
    case match
}
