import SwiftUI

protocol JigsawPuzzleUseCase {
    func createPuzzlePieces(rows: Int, cols: Int) -> [PuzzlePiece]
    func validatePiecePlacement(pieces: PuzzlePiece, dropRow: Int, dropCol: Int) -> Bool
    func isLevelCompleted(placedPieces: [PuzzlePiece], totalPieces: Int) -> Bool
    func getCurrentImage() -> String
    func getCurrentImageIndex() -> Int
    func getTotalImageCount() -> Int
    func nextImage() -> String?
    func resetImages() -> String
}
