//
//  File.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 18/02/25.
//

import Foundation

class SortingPuzzleRepositoryImpl: SortingPuzzleRepository {
    private var currentThemeIndex: Int = 0
    
    private let themes: [SortingPuzzleTheme] = [
        SortingPuzzleTheme(
            id: 1,
            pieceAImageName: "jeans",
            workspaceAImageName: "closet",
            pieceBImageName: "shoes",
            workspaceBImageName: "rackShoes"
        ),
        SortingPuzzleTheme(
            id: 2,
            pieceAImageName: "book",
            workspaceAImageName: "bookshelf",
            pieceBImageName: "pencilpen",
            workspaceBImageName: "pencilpenHolder"
        ),
        SortingPuzzleTheme(
            id: 3,
            pieceAImageName: "trash",
            workspaceAImageName: "trashCan",
            pieceBImageName: "plant",
            workspaceBImageName: "garden"
        ),
        SortingPuzzleTheme(
            id: 4,
            pieceAImageName: "apple",
            workspaceAImageName: "basketFruit",
            pieceBImageName: "wortel",
            workspaceBImageName: "vegetables"
        ),
        SortingPuzzleTheme(
            id: 5,
            pieceAImageName: "basketball",
            workspaceAImageName: "basketballRing",
            pieceBImageName: "soccer",
            workspaceBImageName: "soccerNet"
        )
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
