//
//  SwiftUIView.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 19/02/25.
//

import SwiftUI

struct JigsawCompletionView: View {
    @ObservedObject var viewModel: JigsawPuzzleViewModel
    var onComplete: () -> Void
    
    var body: some View {
        ZStack {
            SuccessOverlay(
                isVisible: viewModel.showSuccessOverlay,
                onComplete: {
                    onComplete()
                }
            )
        }
    }
}
