import SwiftUI
import AVFoundation

@MainActor
final class JigsawPuzzleViewModel: ObservableObject {
    
    let jigsawUseCase: JigsawPuzzleUseCase
    
    @Published var pieces: [PuzzlePiece] = []
    @Published var placedPieces: [PuzzlePiece] = []
    @Published var draggedPiece: PuzzlePiece?
    @Published var currentImageIndex: Int = 0
    @Published var isCompleted: Bool = false
    @Published var showSuccessOverlay: Bool = false
    @Published var shouldReturnToMenu: Bool = false
    
    let rows: Int
    let cols: Int
    
    init(jigsawUseCase: JigsawPuzzleUseCase, rows: Int = 2, cols: Int = 2) {
        self.jigsawUseCase = jigsawUseCase
        self.rows = rows
        self.cols = cols
        
        self.currentImageIndex = jigsawUseCase.getCurrentImageIndex()
        setupInitialState()
        ProgressStore.shared.recordSessionStart(.jigsaw)
    }
    
    private func setupInitialState() {
        pieces = jigsawUseCase.createPuzzlePieces(rows: rows, cols: cols)
    }
    
    func isDraggingPiece(_ pieceId: UUID) -> Bool {
        return draggedPiece?.id == pieceId
    }
    
    func handlePieceDrop(dropPoint: CGPoint, boardFrame: CGRect, pieceSize: CGFloat) {
        guard let piece = draggedPiece else { return }
        
        let droppedPiece = piece 
        withAnimation(.none) {
            self.draggedPiece = nil
        }
        
        // Special-needs-friendly matching: rather than requiring the exact
        // point where the finger lifted to fall inside one specific cell
        // (which forced kids with imprecise motor control to release with
        // near-pixel accuracy), judge the drop by how much of the piece - a
        // pieceSize x pieceSize square centered on the release point, i.e.
        // where it visually was - overlaps each board cell, and pick whichever
        // cell shares the most area with it. A piece that's clearly hovering
        // mostly over the right quadrant lands there even if the fingertip
        // itself ends up a bit outside the board or over a neighboring cell.
        let pieceRect = CGRect(
            x: dropPoint.x - pieceSize / 2,
            y: dropPoint.y - pieceSize / 2,
            width: pieceSize,
            height: pieceSize
        )

        var bestCell: (row: Int, col: Int)?
        var bestOverlapArea: CGFloat = 0

        for row in 0..<rows {
            for col in 0..<cols {
                let cellRect = CGRect(
                    x: boardFrame.minX + CGFloat(col) * pieceSize,
                    y: boardFrame.minY + CGFloat(row) * pieceSize,
                    width: pieceSize,
                    height: pieceSize
                )
                let overlap = cellRect.intersection(pieceRect)
                let overlapArea = overlap.isNull ? 0 : overlap.width * overlap.height
                if overlapArea > bestOverlapArea {
                    bestOverlapArea = overlapArea
                    bestCell = (row, col)
                }
            }
        }

        // At least a quarter of the piece has to be over the board - enough
        // that the drop was clearly aimed at it, not a miss that merely
        // grazed its edge.
        let minimumOverlapArea = (pieceSize * pieceSize) * 0.25
        guard let dropTarget = bestCell, bestOverlapArea >= minimumOverlapArea else {
            Haptic.shared.error()
            ProgressStore.shared.recordIncorrect(.jigsaw)
            return
        }

        let isCorrectPosition = jigsawUseCase.validatePiecePlacement(pieces: droppedPiece, dropRow: dropTarget.row, dropCol: dropTarget.col)
        
        if isCorrectPosition {
            DispatchQueue.main.async {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    if let index = self.pieces.firstIndex(where: { $0.id == droppedPiece.id }) {
                        let placedPiece = self.pieces.remove(at: index)
                        self.placedPieces.append(placedPiece)
                        Haptic.shared.success()
                        AudioPlayerManager.shared.playAudio(named: AudioConstants.correctAction, withExtension: AudioConstants.audioExtension)
                        ProgressStore.shared.recordCorrect(.jigsaw)
                    }
                }

                self.checkLevelCompletion()
            }
        } else {
            Haptic.shared.error()
            AudioPlayerManager.shared.playAudio(named: AudioConstants.incorrectAction, withExtension: AudioConstants.audioExtension)
            ProgressStore.shared.recordIncorrect(.jigsaw)
        }
    }
    
    private func checkLevelCompletion() {
        if jigsawUseCase.isLevelCompleted(placedPieces: placedPieces, totalPieces: rows * cols) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    self.isCompleted = true
                    ProgressStore.shared.recordRoundCompleted(.jigsaw)

                    if self.currentImageIndex < self.getTotalImageCount() - 1 {
                        AudioPlayerManager.shared.playAudio(named: AudioConstants.roundComplete, withExtension: AudioConstants.audioExtension)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.nextLevel()
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation {
                                self.showSuccessOverlay = true
                                AudioPlayerManager.shared.playAudio(named: AudioConstants.puzzleComplete, withExtension: AudioConstants.audioExtension)

                            }
                        }
                    }
                }
            }
        }
    }
    
    func nextLevel() {
        if let _ = jigsawUseCase.nextImage() {
            withAnimation {
                isCompleted = false
                currentImageIndex = jigsawUseCase.getCurrentImageIndex()
                placedPieces = []
                pieces = jigsawUseCase.createPuzzlePieces(rows: rows, cols: cols)
            }
        }
    }
    
    func resetGame() {
        withAnimation {
            isCompleted = false
            showSuccessOverlay = false
            _ = jigsawUseCase.resetImages()
            currentImageIndex = jigsawUseCase.getCurrentImageIndex()
            placedPieces = []
            pieces = jigsawUseCase.createPuzzlePieces(rows: rows, cols: cols)
        }
    }
    
    func getCurrentImageName() -> String {
        return jigsawUseCase.getCurrentImage()
    }
    
    func getTotalImageCount() -> Int {
        return jigsawUseCase.getTotalImageCount()
    }
    
    func finishSuccessAndReturnToMenu() {
        DispatchQueue.main.async {
            self.showSuccessOverlay = false
            self.resetGame() 
            AudioPlayerManager.shared.playBackgroundMusic(
                named: AudioConstants.introMusic,
                withExtension: AudioConstants.audioExtension
            )
            self.shouldReturnToMenu = true
        }
    }
}
