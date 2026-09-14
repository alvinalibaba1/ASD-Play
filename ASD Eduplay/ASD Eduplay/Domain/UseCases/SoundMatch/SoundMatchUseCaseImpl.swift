import Foundation

final class SoundMatchUseCaseImpl: SoundMatchUseCase {
    private let optionCount = 3

    // Reuses the same 6 sound/image pairs Tap & Play already has - concrete,
    // unambiguous everyday sounds rather than anything abstract, so hearing
    // the clip and picking the right picture is a fair, unaided match.
    private let items: [SoundMatchItem] = [
        SoundMatchItem(id: "bell", imageName: "bell", soundName: "bell", label: "Bell"),
        SoundMatchItem(id: "carHorn", imageName: "carHorn", soundName: "carHorn", label: "Car Horn"),
        SoundMatchItem(id: "dog", imageName: "dog 2", soundName: "dog", label: "Dog"),
        SoundMatchItem(id: "drum", imageName: "drum", soundName: "drum", label: "Drum"),
        SoundMatchItem(id: "phone", imageName: "phone", soundName: "phone", label: "Phone"),
        SoundMatchItem(id: "popper", imageName: "popper", soundName: "popper", label: "Party Popper")
    ]

    func createRound() -> SoundMatchRound {
        let target = items.randomElement() ?? items[0]
        var options = Array(items.filter { $0.id != target.id }.shuffled().prefix(optionCount - 1))
        options.append(target)
        options.shuffle()
        return SoundMatchRound(target: target, options: options)
    }

    func checkAnswer(selected: SoundMatchItem, target: SoundMatchItem) -> Bool {
        selected.id == target.id
    }
}
