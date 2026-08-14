//
//  File.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 18/02/25.
//

import Foundation

@MainActor
class TracingPuzzleViewModel: ObservableObject {
    @Published var currentLevel: Int = 1
    @Published var levels: [TracingPuzzleLevel] = []
    @Published var showSuccessOverlay: Bool = false
    @Published var shouldReturnToMenu: Bool = false

    let finalRound = 3

    private let tracingUseCase: TracingPuzzleUseCase

    init(tracingUseCase: TracingPuzzleUseCase) {
        self.tracingUseCase = tracingUseCase
        self.levels = tracingUseCase.setupLevels()
        ProgressStore.shared.recordSessionStart(.tracing)
    }

    func nextLevel() {
        if let nextLevel = tracingUseCase.nextLevel(currentLevel) {
            currentLevel = nextLevel
        }
    }

    func completeLevel() {
        tracingUseCase.completeLevel(currentLevel)
        ProgressStore.shared.recordCorrect(.tracing)
        ProgressStore.shared.recordRoundCompleted(.tracing)

        if currentLevel == finalRound {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                self.showSuccessOverlay = true
                AudioPlayerManager.shared.playAudio(named: AudioConstants.puzzleComplete, withExtension: AudioConstants.audioExtension)
                self.objectWillChange.send()
            }
        } else if currentLevel < finalRound {
            AudioPlayerManager.shared.playAudio(named: AudioConstants.roundComplete, withExtension: AudioConstants.audioExtension)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                guard let self = self else { return }
                self.nextLevel()
            }
        }
    }

    func finishSuccessAndReturnToMenu() {
        guard showSuccessOverlay else { return }

        AudioPlayerManager.shared.stopBackgroundMusic()
        showSuccessOverlay = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            AudioPlayerManager.shared.playBackgroundMusic(
                named: AudioConstants.introMusic,
                withExtension: AudioConstants.audioExtension
            )
            self.shouldReturnToMenu = true
        }
    }
}
