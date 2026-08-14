//
//  SwiftUIView.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 19/02/25.
//

import SwiftUI

struct JigsawDraggedPieceView: View {
    @ObservedObject var viewModel: JigsawPuzzleViewModel
    let pieceSize: CGFloat
    let startLocation: CGPoint
    let dragOffset: CGSize
    
    var body: some View {
        Group {
            if let piece = viewModel.draggedPiece {
                PuzzlePieceView(
                    imageName: viewModel.getCurrentImageName(),
                    row: piece.row,
                    col: piece.col,
                    pieceSize: pieceSize
                )
                .frame(width: pieceSize, height: pieceSize)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green.opacity(0.5), lineWidth: 3)
                )
                .position(
                    x: startLocation.x + dragOffset.width,
                    y: startLocation.y + dragOffset.height
                )
                .scaleEffect(1.1)
                .shadow(radius: 12)
                .animation(.none, value: dragOffset)
            }
        }
    }
}
