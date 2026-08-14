//
//  File.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 16/02/25.
//

import Foundation

protocol SortingPuzzleUseCase {
    func checkPiecePlacement(piece: SortingPuzzlePiece, workspace: Workspace) -> Bool
    func isPuzzleComplete(pieces: [SortingPuzzlePiece]) -> Bool
    func updatePiecePosition(piece: SortingPuzzlePiece, to position: CGPoint) -> SortingPuzzlePiece
    func getNextTheme() -> SortingPuzzleTheme
}


