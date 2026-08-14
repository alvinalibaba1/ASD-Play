//
//  File.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 18/02/25.
//

import Foundation

protocol TracingPuzzleUseCase {
    func setupLevels() -> [TracingPuzzleLevel]
    func completeLevel(_ level: Int)
    func nextLevel(_ currentLevel: Int) -> Int?
}
