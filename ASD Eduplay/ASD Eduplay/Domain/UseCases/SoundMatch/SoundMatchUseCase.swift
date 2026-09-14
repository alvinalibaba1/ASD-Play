import Foundation

protocol SoundMatchUseCase {
    func createRound() -> SoundMatchRound
    func checkAnswer(selected: SoundMatchItem, target: SoundMatchItem) -> Bool
}
