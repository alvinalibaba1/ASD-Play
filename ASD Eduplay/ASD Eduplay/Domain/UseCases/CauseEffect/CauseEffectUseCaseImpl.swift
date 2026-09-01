import SwiftUI

final class CauseEffectUseCaseImpl: CauseEffectUseCase {
    // Illustrated art (generated via Gemini, placed under
    // Assets.xcassets/Image/Tap & Play) instead of SF Symbols - concrete,
    // colorful pictures read faster and feel more rewarding to tap than
    // abstract line icons, especially for younger/nonverbal kids. Items are
    // all everyday objects with an obvious, unambiguous real-world sound
    // (a car honks, a dog barks) rather than symbolic ones like a star or a
    // cloud, which have no real sound tied to them and were confusing.
    private let items: [CauseEffectItem] = [
        CauseEffectItem(id: "bell", imageName: "bell", soundName: "bell", label: "Bell", color: .orange),
        CauseEffectItem(id: "carHorn", imageName: "carHorn", soundName: "carHorn", label: "Car Horn", color: .red),
        CauseEffectItem(id: "drum", imageName: "drum", soundName: "drum", label: "Drum", color: .brown),
        CauseEffectItem(id: "phone", imageName: "phone", soundName: "phone", label: "Phone", color: .teal),
        CauseEffectItem(id: "dog", imageName: "dog 2", soundName: "dog", label: "Dog", color: .brown),
        CauseEffectItem(id: "popper", imageName: "popper", soundName: "popper", label: "Party Popper", color: .green)
    ]

    func getItems() -> [CauseEffectItem] {
        items
    }
}
