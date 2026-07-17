//
//  File.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 14/02/25.
//

import Foundation
import SwiftUI

struct DraggableItemView: View {
    let piece: MatchingPuzzle
    let onDragChanged: (CGSize) -> Void
    let onDragEnded: (CGPoint) -> Void
    
    @GestureState private var isDragging: Bool = false
    
    var body: some View {
        Group {
            if piece.isVisible {  
                Image(piece.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .offset(piece.offSet)
                    .scaleEffect(isDragging ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3), value: isDragging)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.9))
                            .shadow(radius: 3)
                            .frame(width: 90, height: 90)
                    )
                    .gesture(
                        DragGesture(coordinateSpace: .global)
                            .updating($isDragging) { _, state, _ in
                                state = true
                            }
                            .onChanged { value in
                                onDragChanged(value.translation)
                            }
                            .onEnded { value in
                                onDragEnded(value.location)
                            }
                    )
            }
        }
    }
}
