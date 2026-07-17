//
//  File.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 16/02/25.
//

import Foundation

final class CorrectPuzzleUseCaseImpl: CorrectPuzzleUseCase {
    private let themeRepository: CorrectPuzzleRepository
    
    init(themeRepository: CorrectPuzzleRepository) {
        self.themeRepository = themeRepository
    }
    
    func checkPiecePlacement(piece: CorrectPuzzle, workspace: Workspace) -> Bool {
        return piece.correctWorkspaceId == workspace.id
    }
    
    func isPuzzleComplete(pieces: [CorrectPuzzle]) -> Bool {
        return pieces.allSatisfy { $0.isPlaced }
    }
    
    func updatePiecePosition(piece: CorrectPuzzle, to position: CGPoint) -> CorrectPuzzle {
        var updatedPiece = piece
        updatedPiece.currentPosition = position
        return updatedPiece
    }
    
    func getNextTheme() -> CorrectPuzzleTheme {
        let currentIndex = themeRepository.getCurrentThemeIndex()
        themeRepository.updateThemeIndex(currentIndex + 1)
        return themeRepository.getThemes()[currentIndex]
    }
    
    func resetGame() {
        themeRepository.resetThemes()
    }
}
