//
//  File.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 18/02/25.
//

import Foundation
protocol SortingPuzzleRepository {
    func getThemes() -> [SortingPuzzleTheme]
    func getCurrentThemeIndex() -> Int
    func updateThemeIndex(_ index: Int)
}
