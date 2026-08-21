import SwiftUI

final class CauseEffectUseCaseImpl: CauseEffectUseCase {
    // Illustrated art (generated via Gemini, placed under
    // Assets.xcassets/Image/Tap & Play) instead of SF Symbols - concrete,
    // colorful pictures read faster and feel more rewarding to tap than
    // abstract line icons, especially for younger/nonverbal kids. No "popper"
    // item yet - that image didn't come through in the asset batch, so it's
    // left out rather than mixing in a mismatched SF Symbol among real
    // illustrations.
    private let items: [CauseEffectItem] = [
        CauseEffectItem(id: "bell", imageName: "bell", label: "Bell", color: .orange),
        CauseEffectItem(id: "lightbulb", imageName: "lightbulb", label: "Light", color: .yellow),
        CauseEffectItem(id: "star", imageName: "star", label: "Star", color: .purple),
        CauseEffectItem(id: "heart", imageName: "heart", label: "Heart", color: .red),
        CauseEffectItem(id: "cloud", imageName: "cloud", label: "Cloud", color: .blue)
    ]

    func getItems() -> [CauseEffectItem] {
        items
    }
}
