import Foundation

@MainActor
final class CauseEffectViewModel: ObservableObject {
    @Published var items: [CauseEffectItem]
    @Published var activatedIds: Set<String> = []

    init(useCase: CauseEffectUseCase) {
        self.items = useCase.getItems()
        ProgressStore.shared.recordSessionStart(.causeEffect)
    }

    // No failure state and nothing to complete - every tap is its own small
    // reward, and the item resets a moment later so it can be tapped again
    // right away. Built for kids who benefit from a low-pressure, purely
    // sensory "tap and see what happens" activity rather than a scored task.
    func tap(_ item: CauseEffectItem) {
        Haptic.shared.tap()
        AudioPlayerManager.shared.playAudio(named: AudioConstants.correctAction, withExtension: AudioConstants.audioExtension)
        ProgressStore.shared.recordCorrect(.causeEffect)

        activatedIds.insert(item.id)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.activatedIds.remove(item.id)
        }
    }
}
