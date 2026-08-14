//
//  File.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 16/02/25.
//

import Foundation

final class SortingPuzzleUseCaseImpl: SortingPuzzleUseCase {
    private let themeRepository: SortingPuzzleRepository
    
    init(themeRepository: SortingPuzzleRepository) {
        self.themeRepository = themeRepository
    }
    
    func checkPiecePlacement(piece: SortingPuzzlePiece, workspace: Workspace) -> Bool {
        return piece.targetWorkspaceId == workspace.id
    }
    
    func isPuzzleComplete(pieces: [SortingPuzzlePiece]) -> Bool {
        return pieces.allSatisfy { $0.isPlaced }
    }
    
    func updatePiecePosition(piece: SortingPuzzlePiece, to position: CGPoint) -> SortingPuzzlePiece {
        var updatedPiece = piece
        updatedPiece.currentPosition = position
        return updatedPiece
    }
    
    func getNextTheme() -> SortingPuzzleTheme {
        let currentIndex = themeRepository.getCurrentThemeIndex()
        themeRepository.updateThemeIndex(currentIndex + 1)
        return themeRepository.getThemes()[currentIndex]
    }
}
