//
//  SwiftUIView.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 19/02/25.
//

import SwiftUI

struct JigsawBoardView: View {
    @ObservedObject var viewModel: JigsawPuzzleViewModel
    let pieceSize: CGFloat
    let showShadowImage: Bool
    let boardFrameUpdated: (CGRect) -> Void
    
    var body: some View {
        ZStack {
            Image(viewModel.getCurrentImageName())
                .resizable()
                .scaledToFit()
                .opacity(calculateShadowOpacity())
                .frame(
                    width: CGFloat(viewModel.cols) * pieceSize,
                    height: CGFloat(viewModel.rows) * pieceSize
                )
            
            VStack(spacing: 0) {
                ForEach(0..<viewModel.rows, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<viewModel.cols, id: \.self) { col in
                            DropTargetView(
                                row: row,
                                col: col,
                                isTargeted: viewModel.draggedPiece?.row == row && viewModel.draggedPiece?.col == col,
                                pieceSize: pieceSize
                            )
                        }
                    }
                }
            }
            
            ForEach(viewModel.placedPieces) { piece in
                PuzzlePieceView(
                    imageName: viewModel.getCurrentImageName(),
                    row: piece.row,
                    col: piece.col,
                    pieceSize: pieceSize
                )
                .frame(width: pieceSize, height: pieceSize)
                .position(
                    x: CGFloat(piece.col) * pieceSize + pieceSize / 2,
                    y: CGFloat(piece.row) * pieceSize + pieceSize / 2
                )
            }

            // Placed directly in the board's own ZStack (board-local
            // coordinates) rather than positioned from the .global boardFrame
            // captured elsewhere, so it's guaranteed to land exactly in the
            // middle of the board regardless of safe-area/coordinate-space
            // offsets between the board and the outer screen layout.
            if viewModel.isCompleted && !viewModel.showSuccessOverlay {
                JigsawLevelCompleteView()
                    .id(viewModel.currentImageIndex)
                    .transition(.opacity)
            }
        }
        .frame(
            width: CGFloat(viewModel.cols) * pieceSize,
            height: CGFloat(viewModel.rows) * pieceSize
        )
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 8)
        .background(GeometryReader { proxy in
            // Captured in the same named coordinate space as the piece drag
            // gesture (JigsawPuzzleView.jigsawCoordinateSpace) - using .global
            // here while drag position was reported in the ZStack's own local
            // space (or vice versa) meant this frame and the touch location
            // didn't actually agree on where the board was, even though a
            // piece could look correctly placed on screen.
            Color.clear
                .onAppear {
                    boardFrameUpdated(proxy.frame(in: .named(JigsawPuzzleView.jigsawCoordinateSpace)))
                }
                .onChange(of: proxy.frame(in: .named(JigsawPuzzleView.jigsawCoordinateSpace))) { newFrame in
                    boardFrameUpdated(newFrame)
                }
        })
    }
    
    private func calculateShadowOpacity() -> Double {
        if !showShadowImage {
            return 0.0
        }
        
        let baseOpacity: Double = 0.6
        let totalPieces = viewModel.rows * viewModel.cols
        let completionRatio = Double(viewModel.placedPieces.count) / Double(totalPieces)
        return baseOpacity * (1.0 - completionRatio)
    }
}
