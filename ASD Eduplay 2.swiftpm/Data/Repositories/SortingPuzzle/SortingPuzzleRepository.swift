//
//  File.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 18/02/25.
//

import Foundation
protocol CorrectPuzzleRepository {
    func getThemes() -> [CorrectPuzzleTheme]
    func getCurrentThemeIndex() -> Int
    func updateThemeIndex(_ index: Int)
    func resetThemes()
}
