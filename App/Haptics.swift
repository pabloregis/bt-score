import WatchKit
import ScoreEngine

extension PointOutcome {
    /// Vibração do evento, mais forte quanto maior ele é: o jogador sabe o que houve sem olhar.
    var haptic: WKHapticType {
        switch self {
        case .point: .click
        case .game: .directionUp
        case .set: .success
        case .match: .notification
        }
    }

    func play() {
        WKInterfaceDevice.current().play(haptic)
    }
}
