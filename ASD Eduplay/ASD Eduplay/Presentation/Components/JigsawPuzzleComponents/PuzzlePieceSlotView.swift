//
//  SwiftUIView.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 19/02/25.
//

import SwiftUI

struct PuzzlePieceSlotView: View {
    let piece: PuzzlePiece
    @ObservedObject var viewModel: JigsawPuzzleViewModel
    let pieceSize: CGFloat
    let onDragChanged: (DragGesture.Value, PuzzlePiece) -> Void
    let onDragEnded: (DragGesture.Value) -> Void
    
    var body: some View {
        PuzzlePieceView(
            imageName: viewModel.getCurrentImageName(),
            row: piece.row,
            col: piece.col,
            pieceSize: pieceSize
        )
        .frame(width: pieceSize, height: pieceSize)
        .opacity(viewModel.draggedPiece?.id == piece.id ? 0 : 1)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: viewModel.draggedPiece == nil ? 5 : 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(viewModel.draggedPiece == nil ? Color.blue.opacity(0.2) :
                       (viewModel.draggedPiece?.id == piece.id ? Color.green.opacity(0.4) : Color.gray.opacity(0.1)),
                       lineWidth: viewModel.draggedPiece?.id == piece.id ? 3 : 2)
        )
        .scaleEffect(viewModel.draggedPiece?.id == piece.id ? 1.05 : 1.0)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(coordinateSpace: .named(JigsawPuzzleView.jigsawCoordinateSpace))
                .onChanged { value in
                    if viewModel.draggedPiece == nil || viewModel.draggedPiece?.id == piece.id {
                        onDragChanged(value, piece)
                    }
                }
                .onEnded { value in
                    if viewModel.draggedPiece?.id == piece.id {
                        onDragEnded(value)
                    }
                }
        )
        .zIndex(viewModel.draggedPiece?.id == piece.id ? 100 : 1)
    }
}
