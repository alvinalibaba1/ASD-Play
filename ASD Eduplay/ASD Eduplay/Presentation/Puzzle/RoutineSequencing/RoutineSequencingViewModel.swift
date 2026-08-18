import Foundation

@MainActor
final class RoutineSequencingViewModel: ObservableObject {
    @Published var scrambledSteps: [RoutineStep] = []
    @Published var placedSteps: [RoutineStep] = []
    @Published var lastWrongStepId: String?
    @Published var currentSetIndex: Int = 0
    @Published var showSuccessOverlay: Bool = false
    @Published var shouldReturnToMenu: Bool = false

    private let routineSets: [RoutineSet]

    var currentSet: RoutineSet { routineSets[currentSetIndex] }
    var totalSets: Int { routineSets.count }

    init(useCase: RoutineSequencingUseCase) {
        self.routineSets = useCase.getRoutineSets()
        ProgressStore.shared.recordSessionStart(.routineSequencing)
        loadCurrentSet()
    }

    private func loadCurrentSet() {
        scrambledSteps = currentSet.steps.shuffled()
        placedSteps = []
        lastWrongStepId = nil
    }

    // Tap-to-place instead of drag: the child taps steps in the order they
    // happen. Simpler and more forgiving for imprecise motor control than
    // dragging each card into a numbered slot, and avoids the coordinate-space
    // pitfalls dragging ran into elsewhere in this app.
    func selectStep(_ step: RoutineStep) {
        let expectedOrder = placedSteps.count + 1

        if step.order == expectedOrder {
            Haptic.shared.correct()
            AudioPlayerManager.shared.playAudio(named: AudioConstants.correctAction, withExtension: AudioConstants.audioExtension)
            ProgressStore.shared.recordCorrect(.routineSequencing)

            scrambledSteps.removeAll { $0.id == step.id }
            placedSteps.append(step)

            if placedSteps.count == currentSet.steps.count {
                completeSet()
            }
        } else {
            Haptic.shared.error()
            AudioPlayerManager.shared.playAudio(named: AudioConstants.incorrectAction, withExtension: AudioConstants.audioExtension)
            ProgressStore.shared.recordIncorrect(.routineSequencing)

            // Stays available to tap again immediately - no piece is lost or
            // locked out, just a gentle "not yet" cue.
            lastWrongStepId = step.id
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.lastWrongStepId = nil
            }
        }
    }

    private func completeSet() {
        ProgressStore.shared.recordRoundCompleted(.routineSequencing)

        if currentSetIndex >= routineSets.count - 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                AudioPlayerManager.shared.playAudio(named: AudioConstants.puzzleComplete, withExtension: AudioConstants.audioExtension)
                self?.showSuccessOverlay = true
            }
        } else {
            AudioPlayerManager.shared.playAudio(named: AudioConstants.roundComplete, withExtension: AudioConstants.audioExtension)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                guard let self else { return }
                self.currentSetIndex += 1
                self.loadCurrentSet()
            }
        }
    }

    func finishSuccessAndReturnToMenu() {
        AudioPlayerManager.shared.stopBackgroundMusic()
        AudioPlayerManager.shared.playBackgroundMusic(named: AudioConstants.introMusic, withExtension: AudioConstants.audioExtension)
        shouldReturnToMenu = true
    }
}
