//
//  SwiftUIView.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 14/02/25.
//
import SwiftUI

struct MatchingPiecesGridView: View {
    let pieces: [MatchingPuzzle]
    let targetPosition: CGRect
    let onPieceDrop: (MatchingPuzzle, CGPoint, CGRect) -> Void
    let onPieceMove: (MatchingPuzzle, CGSize) -> Void
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 25) {
            ForEach(pieces.filter { $0.isVisible }) { piece in
                DraggableItemView(
                    piece: piece,
                    onDragChanged: { translation in
                        onPieceMove(piece, translation)
                    },
                    onDragEnded: { location in
                        onPieceDrop(piece, location, targetPosition)
                    }
                )
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 50)
    }
}
