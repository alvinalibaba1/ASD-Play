//
//  File.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 18/02/25.
//

import Foundation

class CorrectPuzzleRepositoryImpl: CorrectPuzzleRepository {
    private var currentThemeIndex: Int = 0
    
    private let themes: [CorrectPuzzleTheme] = [
        CorrectPuzzleTheme(
            id: 1,
            pieceAImageName: "jeans",
            workspaceAImageName: "closet",
            pieceBImageName: "shoes",
            workspaceBImageName: "rackShoes"
        ),
        CorrectPuzzleTheme(
            id: 2,
            pieceAImageName: "book",
            workspaceAImageName: "bookshelf",
            pieceBImageName: "pencilpen",
            workspaceBImageName: "pencilpenHolder"
        ),
        CorrectPuzzleTheme(
            id: 3,
            pieceAImageName: "trash",
            workspaceAImageName: "trashCan",
            pieceBImageName: "plant",
            workspaceBImageName: "garden"
        ),
        CorrectPuzzleTheme(
            id: 4,
            pieceAImageName: "apple",
            workspaceAImageName: "basketFruit",
            pieceBImageName: "wortel",
            workspaceBImageName: "vegetables"
        ),
        CorrectPuzzleTheme(
            id: 5,
            pieceAImageName: "basketball",
            workspaceAImageName: "basketballRing",
            pieceBImageName: "soccer",
            workspaceBImageName: "soccerNet"
        )
    ]
    func getThemes() -> [CorrectPuzzleTheme] {
        return themes
    }
    
    func getCurrentThemeIndex() -> Int {
        return currentThemeIndex
    }
    
    func updateThemeIndex(_ index: Int) {
        currentThemeIndex = index % themes.count
    }
    
    func resetThemes() {
        currentThemeIndex = 0
    }
}
