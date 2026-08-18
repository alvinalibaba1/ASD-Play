import Foundation

protocol EmotionMatchingUseCase {
    func createRound() -> EmotionMatchingRound
    func checkAnswer(selected: Emotion, target: Emotion) -> Bool
}
