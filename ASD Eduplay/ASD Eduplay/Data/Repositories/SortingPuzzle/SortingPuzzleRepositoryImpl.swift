//
//  File.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 18/02/25.
//

import Foundation
import SwiftUI

class SortingPuzzleRepositoryImpl: SortingPuzzleRepository {
    private var currentThemeIndex: Int = 0

    // Previously each round paired a real-world object with the container it
    // "belongs" in (jeans -> closet, a pencil -> a pencil holder, etc.). That
    // requires knowing what those objects are for - a harder, more abstract
    // categorization task than Matching's identical-image matching, and it
    // made the two games feel like the same mechanic with an extra layer of
    // confusion on top. Sorting by color instead tests a single, immediately
    // visible property with no real-world reasoning required: the circle is
    // red, the bin is red, they go together - while still being a distinct
    // skill from Matching (sorting into a category vs. matching to one exact
    // target).
    private let themes: [SortingPuzzleTheme] = [
        SortingPuzzleTheme(id: 1, colorA: .red, labelA: "Red", colorB: .blue, labelB: "Blue"),
        SortingPuzzleTheme(id: 2, colorA: .yellow, labelA: "Yellow", colorB: .green, labelB: "Green"),
        SortingPuzzleTheme(id: 3, colorA: .purple, labelA: "Purple", colorB: .orange, labelB: "Orange"),
        SortingPuzzleTheme(id: 4, colorA: .pink, labelA: "Pink", colorB: .brown, labelB: "Brown"),
        SortingPuzzleTheme(id: 5, colorA: .cyan, labelA: "Cyan", colorB: .indigo, labelB: "Indigo")
    ]
    func getThemes() -> [SortingPuzzleTheme] {
        return themes
    }
    
    func getCurrentThemeIndex() -> Int {
        return currentThemeIndex
    }
    
    func updateThemeIndex(_ index: Int) {
        currentThemeIndex = index % themes.count
    }
}
