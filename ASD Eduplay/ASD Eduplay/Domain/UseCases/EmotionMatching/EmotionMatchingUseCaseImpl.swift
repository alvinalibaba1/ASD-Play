import Foundation

final class EmotionMatchingUseCaseImpl: EmotionMatchingUseCase {
    private let optionCount = 3

    func createRound() -> EmotionMatchingRound {
        let target = Emotion.allCases.randomElement() ?? .happy
        var options = Emotion.allCases.filter { $0 != target }.shuffled().prefix(optionCount - 1) + [target]
        options.shuffle()
        return EmotionMatchingRound(target: target, options: Array(options))
    }

    func checkAnswer(selected: Emotion, target: Emotion) -> Bool {
        selected == target
    }
}
