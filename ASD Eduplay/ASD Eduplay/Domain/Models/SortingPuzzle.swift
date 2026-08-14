import SwiftUI
import Foundation

struct SortingPuzzleTheme {
    let id: Int
    let pieceAImageName: String
    let workspaceAImageName: String
    let pieceBImageName: String
    let workspaceBImageName: String
}

struct SortingPuzzlePiece: Identifiable {
    let id: String
    let targetWorkspaceId: String
    var currentPosition: CGPoint
    var isPlaced: Bool
    let imageName: String

    init(id: String, targetWorkspaceId: String, initialPosition: CGPoint, imageName: String) {
        self.id = id
        self.targetWorkspaceId = targetWorkspaceId
        self.currentPosition = initialPosition
        self.isPlaced = false
        self.imageName = imageName
    }
}


struct Workspace {
    let id: String
    let position: CGPoint
    let imageName: String
    var occupyingPieceId: String?
}
