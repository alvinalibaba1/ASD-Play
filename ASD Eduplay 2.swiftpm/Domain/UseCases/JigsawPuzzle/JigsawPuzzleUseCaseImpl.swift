import SwiftUI

import SwiftUI

final class JigsawPuzzleUseCaseImpl: JigsawPuzzleUseCase {
    private let repository: JigsawPuzzleRepository
    
    init(repository: JigsawPuzzleRepository) {
        self.repository = repository
    }
    
    func createPuzzlePieces(rows: Int, cols: Int) -> [PuzzlePiece] {
        var newPieces: [PuzzlePiece] = []
        for row in 0..<rows {
            for col in 0..<cols {
                newPieces.append(PuzzlePiece(row: row, col: col))
            }
        }
        return newPieces.shuffled()
    }
    
    func validatePiecePlacement(pieces: PuzzlePiece, dropRow: Int, dropCol: Int) -> Bool {
        let isValid = pieces.row == dropRow && pieces.col == dropCol
        print("Validating - Piece(\(pieces.row),\(pieces.col)) at position(\(dropRow),\(dropCol)) - Valid: \(isValid)")
        return isValid
    }
    
    func isLevelCompleted(placedPieces: [PuzzlePiece], totalPieces: Int) -> Bool {
        return placedPieces.count == totalPieces
    }
    
    func getCurrentImage() -> String {
        let imageNames = repository.getImageNames()
        let currentIndex = repository.getCurrentImageIndex()
        return imageNames[currentIndex]
    }
    
    func getCurrentImageIndex() -> Int {
        return repository.getCurrentImageIndex()
    }
    
    func getTotalImageCount() -> Int {
        return repository.getTotalImageCount()
    }
    
    func nextImage() -> String? {
        let currentIndex = repository.getCurrentImageIndex()
        let totalImages = repository.getTotalImageCount()
        
        if currentIndex < totalImages - 1 {
            repository.updateImageIndex(currentIndex + 1)
            return repository.getImageNames()[currentIndex + 1]
        }
        return nil
    }
    
    func resetImages() -> String {
        repository.resetImageIndex()
        return repository.getImageNames()[0]
    }
}
