import Foundation

@MainActor
final class EmotionMatchingViewModel: ObservableObject {
    @Published var currentRound: EmotionMatchingRound
    @Published var roundsCompleted: Int = 0
    @Published var lastSelection: Emotion?
    @Published var showSuccessOverlay: Bool = false
    @Published var shouldReturnToMenu: Bool = false

    let totalRounds = 5

    private let useCase: EmotionMatchingUseCase

    init(useCase: EmotionMatchingUseCase) {
        self.useCase = useCase
        self.currentRound = useCase.createRound()
        ProgressStore.shared.recordSessionStart(.emotionMatching)
    }

    func selectAnswer(_ emotion: Emotion) {
        lastSelection = emotion

        if useCase.checkAnswer(selected: emotion, target: currentRound.target) {
            Haptic.shared.correct()
            AudioPlayerManager.shared.playAudio(named: AudioConstants.correctAction, withExtension: AudioConstants.audioExtension)
            ProgressStore.shared.recordCorrect(.emotionMatching)
            ProgressStore.shared.recordRoundCompleted(.emotionMatching)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.advance()
            }
        } else {
            Haptic.shared.error()
            AudioPlayerManager.shared.playAudio(named: AudioConstants.incorrectAction, withExtension: AudioConstants.audioExtension)
            ProgressStore.shared.recordIncorrect(.emotionMatching)

            // No penalty beyond the sound/haptic - the round stays open so the
            // child can simply try again instead of losing progress.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                self?.lastSelection = nil
            }
        }
    }

    private func advance() {
        roundsCompleted += 1
        lastSelection = nil

        if roundsCompleted >= totalRounds {
            AudioPlayerManager.shared.playAudio(named: AudioConstants.puzzleComplete, withExtension: AudioConstants.audioExtension)
            showSuccessOverlay = true
        } else {
            AudioPlayerManager.shared.playAudio(named: AudioConstants.roundComplete, withExtension: AudioConstants.audioExtension)
            currentRound = useCase.createRound()
        }
    }

    func finishSuccessAndReturnToMenu() {
        AudioPlayerManager.shared.stopBackgroundMusic()
        AudioPlayerManager.shared.playBackgroundMusic(named: AudioConstants.introMusic, withExtension: AudioConstants.audioExtension)
        shouldReturnToMenu = true
    }
}
