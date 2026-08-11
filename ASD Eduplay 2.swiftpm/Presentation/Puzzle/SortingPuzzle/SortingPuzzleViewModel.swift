//
//  File.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 16/02/25.
//

import Foundation
import SwiftUI

@MainActor
class SortingPuzzleViewModel: ObservableObject {
    @Published private(set) var puzzlePieces: [CorrectPuzzle]
    @Published private(set) var workspaces: [Workspace]
    @Published var isComplete: Bool = false
    @Published var currentRound: Int = 1
    @Published private(set) var currentTheme: CorrectPuzzleTheme
    @Published var shouldReturnToMenu: Bool = false
    
    private let sortingUseCase: CorrectPuzzleUseCase
    
    init(sortingUseCase: CorrectPuzzleUseCase) {
        self.sortingUseCase = sortingUseCase
        
        let theme = sortingUseCase.getNextTheme()
        self.currentTheme = theme
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let workspaceY = screenHeight * 0.3
        let pieceY = screenHeight * 0.7
        let pieceSpacing: CGFloat = 300
        let centerX = screenWidth / 2
        
        self.workspaces = [
            Workspace(
                id: "workspaceA",
                position: CGPoint(x: screenWidth * 0.25, y: workspaceY),
                imageName: theme.workspaceAImageName
            ),
            Workspace(
                id: "workspaceB",
                position: CGPoint(x: screenWidth * 0.75, y: workspaceY),
                imageName: theme.workspaceBImageName
            )
        ]
        
        self.puzzlePieces = [
            CorrectPuzzle(
                id: "A",
                correctWorkspaceId: "workspaceA",
                initialPosition: CGPoint(x: centerX - pieceSpacing/2, y: pieceY),
                imageName: theme.pieceAImageName
            ),
            CorrectPuzzle(
                id: "B",
                correctWorkspaceId: "workspaceB",
                initialPosition: CGPoint(x: centerX + pieceSpacing/2, y: pieceY),
                imageName: theme.pieceBImageName
            )
        ]

        ProgressStore.shared.recordSessionStart(.sorting)
    }

    func nextRound() {
        if currentRound < 5 {
            currentRound += 1
            currentTheme = sortingUseCase.getNextTheme()
            resetPieces()
            isComplete = false
        }
    }
    
    func resetGame() {
        currentRound = 1
        sortingUseCase.resetGame()
        currentTheme = sortingUseCase.getNextTheme()
        resetPieces()
        isComplete = false
    }
    
    private func resetPieces() {
        let theme = self.currentTheme
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let pieceY = screenHeight * 0.7
        let pieceSpacing: CGFloat = 300
        let centerX = screenWidth / 2
        
        workspaces = [
            Workspace(
                id: "workspaceA",
                position: CGPoint(x: screenWidth * 0.25, y: screenHeight * 0.3),
                imageName: theme.workspaceAImageName
            ),
            Workspace(
                id: "workspaceB",
                position: CGPoint(x: screenWidth * 0.75, y: screenHeight * 0.3),
                imageName: theme.workspaceBImageName
            )
        ]
        
        puzzlePieces = [
            CorrectPuzzle(
                id: "A",
                correctWorkspaceId: "workspaceA",
                initialPosition: CGPoint(x: centerX - pieceSpacing/2, y: pieceY),
                imageName: theme.pieceAImageName
            ),
            CorrectPuzzle(
                id: "B",
                correctWorkspaceId: "workspaceB",
                initialPosition: CGPoint(x: centerX + pieceSpacing/2, y: pieceY),
                imageName: theme.pieceBImageName
            )
        ]
    }
    
    private func autoAdvanceAfterDelay() {
        guard currentRound < 5 else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            self.nextRound()
        }
    }
    
    func movePiece(_ piece: CorrectPuzzle, to position: CGPoint, isDragging: Bool) {
        guard let index = puzzlePieces.firstIndex(where: { $0.id == piece.id }) else { return }
        
        if isDragging {
            puzzlePieces[index] = sortingUseCase.updatePiecePosition(piece: piece, to: position)
        } else {
            if let workspace = findNearestWorkspace(to: position) {
                let isCorrect = sortingUseCase.checkPiecePlacement(piece: piece, workspace: workspace)
                if isCorrect {
                    AudioPlayerManager.shared.playCorrectActionSound()
                    var updatedPiece = piece
                    updatedPiece.currentPosition = workspace.position
                    updatedPiece.isPlaced = true
                    puzzlePieces[index] = updatedPiece
                    
                    Haptic.shared.correct()
                    ProgressStore.shared.recordCorrect(.sorting)

                    let completionStatus = sortingUseCase.isPuzzleComplete(pieces: puzzlePieces)
                    isComplete = completionStatus

                    if completionStatus {
                        ProgressStore.shared.recordRoundCompleted(.sorting)
                        if currentRound == 5 {
                            AudioPlayerManager.shared.playPuzzleCompleteSound()
                        } else {
                            AudioPlayerManager.shared.playRoundCompleteSound()
                        }
                        autoAdvanceAfterDelay()
                    }
                } else {
                    AudioPlayerManager.shared.playIncorrectActionSound()
                    let originalPosition = getOriginalPosition(for: piece.id)
                    puzzlePieces[index] = sortingUseCase.updatePiecePosition(piece: piece, to: originalPosition)

                    Haptic.shared.error()
                    ProgressStore.shared.recordIncorrect(.sorting)
                }
            } else {
                let originalPosition = getOriginalPosition(for: piece.id)
                puzzlePieces[index] = sortingUseCase.updatePiecePosition(piece: piece, to: originalPosition)
            }
        }
    }
    
    func finishSuccessAndReturnToMenu() {
        AudioPlayerManager.shared.stopBackgroundMusic()

        AudioPlayerManager.shared.playBackgroundMusic(
            named: AudioConstants.introMusic,
                    withExtension: AudioConstants.audioExtension
                )
            DispatchQueue.main.async {
                self.shouldReturnToMenu = true
            }
        }
    
    private func findNearestWorkspace(to position: CGPoint) -> Workspace? {
        let threshold: CGFloat = 100.0
        return workspaces.first { workspace in
            let distance = hypot(position.x - workspace.position.x,
                                 position.y - workspace.position.y)
            return distance < threshold
        }
    }
    
    private func getOriginalPosition(for pieceId: String) -> CGPoint {
        let screenWidth = UIScreen.main.bounds.width
        let pieceY = UIScreen.main.bounds.height * 0.7
        let pieceSpacing: CGFloat = 300
        let centerX = screenWidth / 2
        
        return pieceId == "A"
        ? CGPoint(x: centerX - pieceSpacing/2, y: pieceY)
        : CGPoint(x: centerX + pieceSpacing/2, y: pieceY)
    }
    
}
