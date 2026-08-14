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
    @Published private(set) var puzzlePieces: [SortingPuzzlePiece] = []
    @Published private(set) var workspaces: [Workspace] = []
    @Published var isComplete: Bool = false
    @Published var currentRound: Int = 1
    @Published private(set) var currentTheme: SortingPuzzleTheme
    @Published var shouldReturnToMenu: Bool = false

    private let sortingUseCase: SortingPuzzleUseCase
    private var containerSize: CGSize = .zero

    // Capped at the original iPad-tuned spread so it doesn't scale up beyond
    // that, but shrinks proportionally on narrower screens instead of pushing
    // pieces toward (or past) the edges. The height * 0.45 term matters on
    // landscape iPhone specifically: workspaces sit at 30% height and pieces at
    // 70%, so on a short canvas a width-only size could be tall enough to clip
    // off the top of the screen and overlap the piece row below it.
    private var pieceSpacing: CGFloat {
        min(containerSize.width * 0.35, containerSize.height * 0.45, 300)
    }

    init(sortingUseCase: SortingPuzzleUseCase) {
        self.sortingUseCase = sortingUseCase
        self.currentTheme = sortingUseCase.getNextTheme()
        ProgressStore.shared.recordSessionStart(.sorting)
    }

    /// Called by the view whenever its rendered size is known or changes (including
    /// rotation), so pieces are laid out for the actual canvas instead of whatever
    /// screen size happened to be current when this view model was created.
    func updateLayout(containerSize: CGSize) {
        guard containerSize.width > 0, containerSize.height > 0, containerSize != self.containerSize else { return }
        self.containerSize = containerSize
        resetPieces()
    }

    func nextRound() {
        if currentRound < 5 {
            currentRound += 1
            currentTheme = sortingUseCase.getNextTheme()
            resetPieces()
            isComplete = false
        }
    }

    private func resetPieces() {
        guard containerSize.width > 0, containerSize.height > 0 else { return }

        let theme = self.currentTheme
        let size = containerSize
        let workspaceY = size.height * 0.3
        let pieceY = size.height * 0.7
        let centerX = size.width / 2

        workspaces = [
            Workspace(
                id: "workspaceA",
                position: CGPoint(x: size.width * 0.25, y: workspaceY),
                imageName: theme.workspaceAImageName
            ),
            Workspace(
                id: "workspaceB",
                position: CGPoint(x: size.width * 0.75, y: workspaceY),
                imageName: theme.workspaceBImageName
            )
        ]

        puzzlePieces = [
            SortingPuzzlePiece(
                id: "A",
                targetWorkspaceId: "workspaceA",
                initialPosition: CGPoint(x: centerX - pieceSpacing/2, y: pieceY),
                imageName: theme.pieceAImageName
            ),
            SortingPuzzlePiece(
                id: "B",
                targetWorkspaceId: "workspaceB",
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
    
    func movePiece(_ piece: SortingPuzzlePiece, to position: CGPoint, isDragging: Bool) {
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
        let threshold: CGFloat = 130.0
        return workspaces.first { workspace in
            let distance = hypot(position.x - workspace.position.x,
                                 position.y - workspace.position.y)
            return distance < threshold
        }
    }
    
    private func getOriginalPosition(for pieceId: String) -> CGPoint {
        let pieceY = containerSize.height * 0.7
        let centerX = containerSize.width / 2

        return pieceId == "A"
        ? CGPoint(x: centerX - pieceSpacing/2, y: pieceY)
        : CGPoint(x: centerX + pieceSpacing/2, y: pieceY)
    }
    
}
