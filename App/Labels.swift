import SwiftUI
import ScoreEngine

extension Team {
    var label: LocalizedStringKey {
        switch self {
        case .us: "Nós"
        case .them: "Eles"
        }
    }
}

extension Player {
    var label: LocalizedStringKey {
        switch self {
        case .me: "Eu"
        case .partner: "Parceiro"
        case .opponent1: "Adversário 1"
        case .opponent2: "Adversário 2"
        }
    }

    /// Rótulo curto para o placar, onde o espaço é pequeno.
    var shortLabel: LocalizedStringKey {
        switch self {
        case .me: "Eu"
        case .partner: "Parceiro"
        case .opponent1: "Adv. 1"
        case .opponent2: "Adv. 2"
        }
    }
}
