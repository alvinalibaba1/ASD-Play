import SwiftUI
import Foundation

// Sort-by-color: a round pairs one color/label to sort into its matching bin
// (see SortingPuzzleRepositoryImpl for why this replaced the previous
// real-world "this object belongs in that container" pairs).
struct SortingPuzzleTheme {
    let id: Int
    let colorA: Color
    let labelA: String
    let colorB: Color
    let labelB: String
}

struct SortingPuzzlePiece: Identifiable {
    let id: String
    let targetWorkspaceId: String
    var currentPosition: CGPoint
    var isPlaced: Bool
    let color: Color

    init(id: String, targetWorkspaceId: String, initialPosition: CGPoint, color: Color) {
        self.id = id
        self.targetWorkspaceId = targetWorkspaceId
        self.currentPosition = initialPosition
        self.isPlaced = false
        self.color = color
    }
}


struct Workspace {
    let id: String
    let position: CGPoint
    let color: Color
    let label: String
    var occupyingPieceId: String?
}
