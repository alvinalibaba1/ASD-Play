//
//  File.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 16/02/25.
//

import Foundation

protocol CorrectPuzzleUseCase {
    func checkPiecePlacement(piece: CorrectPuzzle, workspace: Workspace) -> Bool
    func isPuzzleComplete(pieces: [CorrectPuzzle]) -> Bool
    func updatePiecePosition(piece: CorrectPuzzle, to position: CGPoint) -> CorrectPuzzle
    func getNextTheme() -> CorrectPuzzleTheme
    func resetGame()
}


