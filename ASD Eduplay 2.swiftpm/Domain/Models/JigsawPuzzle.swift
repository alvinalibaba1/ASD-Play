import Foundation
import SwiftUI


struct PuzzlePiece: Identifiable, Equatable {
    let id = UUID()
    let row: Int
    let col: Int
    var position: CGPoint = .zero
    var isPlaced: Bool = false
    var scale: CGFloat = 1.0
    var rotation: Double = 0.0
}
