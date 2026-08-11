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
        
        let isInBoard = boardFrame.contains(dropPoint)
        
        if !isInBoard {
            Haptic.shared.error()
            ProgressStore.shared.recordIncorrect(.jigsaw)
            return
        }
        
        let relativeX = dropPoint.x - boardFrame.minX
        let relativeY = dropPoint.y - boardFrame.minY
        let dropCol = max(0, min(cols - 1, Int(relativeX / pieceSize)))
        let dropRow = max(0, min(rows - 1, Int(relativeY / pieceSize)))
        
        let isCorrectPosition = jigsawUseCase.validatePiecePlacement(pieces: droppedPiece, dropRow: dropRow, dropCol: dropCol)
        
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
            jigsawUseCase.resetImages()
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
