//
//  SwiftUIView.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 19/02/25.
//

import SwiftUI

struct EmptySlotView: View {
    let pieceSize: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.1))
            .frame(width: pieceSize, height: pieceSize)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 2)
            )
    }
}
