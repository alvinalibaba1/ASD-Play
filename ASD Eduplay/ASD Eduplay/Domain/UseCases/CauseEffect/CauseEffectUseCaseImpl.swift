import SwiftUI

final class CauseEffectUseCaseImpl: CauseEffectUseCase {
    private let items: [CauseEffectItem] = [
        CauseEffectItem(id: "bell", icon: "bell", activatedIcon: "bell.fill", label: "Bell", color: .orange),
        CauseEffectItem(id: "popper", icon: "party.popper", activatedIcon: "party.popper.fill", label: "Popper", color: .pink),
        CauseEffectItem(id: "lightbulb", icon: "lightbulb", activatedIcon: "lightbulb.fill", label: "Light", color: .yellow),
        CauseEffectItem(id: "star", icon: "star", activatedIcon: "star.fill", label: "Star", color: .purple),
        CauseEffectItem(id: "heart", icon: "heart", activatedIcon: "heart.fill", label: "Heart", color: .red),
        CauseEffectItem(id: "cloud", icon: "cloud", activatedIcon: "cloud.rain.fill", label: "Cloud", color: .blue)
    ]

    func getItems() -> [CauseEffectItem] {
        items
    }
}
