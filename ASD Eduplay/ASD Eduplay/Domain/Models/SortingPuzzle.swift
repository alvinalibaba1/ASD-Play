import SwiftUI

import Foundation

struct CorrectPuzzleTheme {
    let id: Int
    let pieceAImageName: String
    let workspaceAImageName: String
    let pieceBImageName: String
    let workspaceBImageName: String
}

struct CorrectPuzzle: Identifiable {
    let id: String
    let correctWorkspaceId: String
    var currentPosition: CGPoint
    var isPlaced: Bool
    let imageName: String
    
    init(id: String, correctWorkspaceId: String, initialPosition: CGPoint, imageName: String) {
        self.id = id
        self.correctWorkspaceId = correctWorkspaceId
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
