//
//  File.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 18/02/25.
//

import Foundation

class TracingPuzzleUseCaseImpl: TracingPuzzleUseCase {
    private let repository: TracingPuzzleRepository
    
    init(repository: TracingPuzzleRepository) {
        self.repository = repository
    }
    
    func setupLevels() -> [TracingPuzzleLevel] {
        return repository.getLevels()
    }
    
    func completeLevel(_ level: Int) {
        repository.updateLevelCompletion(level: level, isCompleted: true)
    }
    
    func resetLevel(_ level: Int) {
        repository.updateLevelCompletion(level: level, isCompleted: false)
    }
    
    func nextLevel(_ currentLevel: Int) -> Int? {
        let totalLevels = repository.getTotalLevels()
        return currentLevel < totalLevels ? currentLevel + 1 : nil
    }
}
