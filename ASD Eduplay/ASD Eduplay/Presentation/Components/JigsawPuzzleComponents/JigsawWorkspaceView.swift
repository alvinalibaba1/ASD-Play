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

    private static let headerHeight: CGFloat = 36
    private static let outerPadding: CGFloat = 16
    private static let rowSpacing: CGFloat = 16

    /// Fixed vertical space this view needs beyond its two piece rows (header +
    /// top/bottom padding + the gap between rows). JigsawPuzzleView subtracts this
    /// from the workspace's allotted height before sizing pieces, so the exact
    /// values here and the ones actually used in `body` must stay in sync.
    static let chromeHeight: CGFloat = headerHeight + outerPadding * 2 + rowSpacing

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.blue.opacity(0.1))
                .frame(height: Self.headerHeight)
                .clipShape(
                    RoundedCorner(radius: 16, corners: [.topLeft, .topRight])
                )

            VStack(spacing: Self.rowSpacing) {
                pieceRow(startIndex: 0)

                pieceRow(startIndex: 2)
            }
            .padding(Self.outerPadding)
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
        HStack(spacing: 20) {
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
