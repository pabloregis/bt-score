/// Pontuação de uma dupla dentro de um game normal.
public enum GameScore: Hashable, Sendable {
    case love
    case fifteen
    case thirty
    case forty

    init(points: Int) {
        self = [.love, .fifteen, .thirty, .forty][points]
    }
}
