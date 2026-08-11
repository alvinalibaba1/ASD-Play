//
//  File.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 18/02/25.
//

import Foundation

protocol TracingPuzzleRepository {
    func getLevels() -> [TracingPuzzleLevel]
    func getTotalLevels() -> Int
    func updateLevelCompletion(level: Int, isCompleted: Bool)
}
