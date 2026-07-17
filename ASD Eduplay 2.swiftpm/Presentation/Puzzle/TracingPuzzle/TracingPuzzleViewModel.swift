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
    @Published var shouldShowReset: Bool = false
    @Published var completedLevels: Set<Int> = []
    @Published var allLevelsCompleted: Bool = false
    @Published var showSuccessOverlay: Bool = false
    @Published var shouldReturnToMenu: Bool = false
    
    
    let finalRound = 3
    
    private let tracingUseCase: TracingPuzzleUseCase
    
    init(tracingUseCase: TracingPuzzleUseCase) {
        self.tracingUseCase = tracingUseCase
        self.levels = tracingUseCase.setupLevels()
    }
    
    func resetLevel() {
        tracingUseCase.resetLevel(currentLevel)
        shouldShowReset = false
        objectWillChange.send()
    }
    
    func nextLevel() {
        if let nextLevel = tracingUseCase.nextLevel(currentLevel) {
            currentLevel = nextLevel
            shouldShowReset = false
        } else {
            allLevelsCompleted = true
        }
    }
    
    func completeLevel() {
        tracingUseCase.completeLevel(currentLevel)
        completedLevels.insert(currentLevel)
        shouldShowReset = true
        
        if currentLevel == finalRound {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                print("Setting showSuccessOverlay to true")
                self.showSuccessOverlay = true
                AudioPlayerManager.shared.playAudio(named: AudioConstants.puzzleComplete, withExtension: AudioConstants.audioExtension)
                self.objectWillChange.send()
            }
        } else if currentLevel < finalRound {
            AudioPlayerManager.shared.playAudio(named: AudioConstants.roundComplete, withExtension: AudioConstants.audioExtension)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                guard let self = self else { return }
                self.nextLevel()
                self.shouldShowReset = false
            }
        }
    }
    
    func hideSuccessOverlayAndReturnToMenu() {
        print("Hiding success overlay and preparing to return to menu")
        showSuccessOverlay = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            print("Setting shouldReturnToMenu to true")
            self.shouldReturnToMenu = true
        }
    }
    
    func restartGame() {
        currentLevel = 1
        completedLevels.removeAll()
        allLevelsCompleted = false
        showSuccessOverlay = false
        
        for level in 1...3 {
            tracingUseCase.resetLevel(level)
        }
        
        shouldShowReset = false
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
