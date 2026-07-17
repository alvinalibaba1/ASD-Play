//
//  SwiftUIView.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 19/02/25.
//

import SwiftUI

struct JigsawWorkspaceView: View {
    @ObservedObject var viewModel: JigsawPuzzleViewModel
    let pieceSize: CGFloat
    let disableInteractions: Bool
    let onDragChanged: (DragGesture.Value, PuzzlePiece) -> Void
    let onDragEnded: (DragGesture.Value) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.blue.opacity(0.1))
                .frame(height: 60)
                .clipShape(
                    RoundedCorner(radius: 16, corners: [.topLeft, .topRight])
                )
            
            VStack(spacing: 30) {
                pieceRow(startIndex: 0)
                
                pieceRow(startIndex: 2)
            }
            .padding(30)
            .background(Color.white)
            .clipShape(
                RoundedCorner(radius: 16, corners: [.bottomLeft, .bottomRight])
            )
        }
        .frame(width: pieceSize * 2.8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.2), lineWidth: 2)
                .shadow(radius: 8)
        )
        .allowsHitTesting(!disableInteractions)
    }
    
    private func pieceRow(startIndex: Int) -> some View {
        HStack(spacing: 30) {
            ForEach(0..<2) { index in
                let pieceIndex = startIndex + index
                if pieceIndex < viewModel.pieces.count {
                    PuzzlePieceSlotView(
                        piece: viewModel.pieces[pieceIndex],
                        viewModel: viewModel,
                        pieceSize: pieceSize,
                        onDragChanged: onDragChanged,
                        onDragEnded: onDragEnded
                    )
                } else {
                    EmptySlotView(pieceSize: pieceSize)
                }
            }
        }
    }
}
