import Foundation

@MainActor
final class SoundMatchViewModel: ObservableObject {
    @Published var currentRound: SoundMatchRound
    @Published var roundsCompleted: Int = 0
    @Published var lastSelection: SoundMatchItem?
    @Published var showSuccessOverlay: Bool = false
    @Published var shouldReturnToMenu: Bool = false

    let totalRounds = 5

    private let useCase: SoundMatchUseCase

    init(useCase: SoundMatchUseCase) {
        self.useCase = useCase
        self.currentRound = useCase.createRound()
        ProgressStore.shared.recordSessionStart(.soundMatch)

        // The whole mechanic depends on hearing the sound before choosing,
        // so the round's target plays on its own rather than waiting for a
        // manual first tap - the replay button covers hearing it again.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.playTargetSound()
        }
    }

    func playTargetSound() {
        AudioPlayerManager.shared.playAudio(named: currentRound.target.soundName, withExtension: AudioConstants.audioExtension)
    }

    func selectAnswer(_ item: SoundMatchItem) {
        lastSelection = item

        if useCase.checkAnswer(selected: item, target: currentRound.target) {
            Haptic.shared.correct()
            AudioPlayerManager.shared.playAudio(named: AudioConstants.correctAction, withExtension: AudioConstants.audioExtension)
            ProgressStore.shared.recordCorrect(.soundMatch)
            ProgressStore.shared.recordRoundCompleted(.soundMatch)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.advance()
            }
        } else {
            Haptic.shared.error()
            AudioPlayerManager.shared.playAudio(named: AudioConstants.incorrectAction, withExtension: AudioConstants.audioExtension)
            ProgressStore.shared.recordIncorrect(.soundMatch)

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

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
                self?.playTargetSound()
            }
        }
    }

    func finishSuccessAndReturnToMenu() {
        AudioPlayerManager.shared.stopBackgroundMusic()
        AudioPlayerManager.shared.playBackgroundMusic(named: AudioConstants.introMusic, withExtension: AudioConstants.audioExtension)
        shouldReturnToMenu = true
    }
}
