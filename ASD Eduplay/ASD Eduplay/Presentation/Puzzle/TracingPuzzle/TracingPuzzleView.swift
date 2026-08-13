//
//  SwiftUIView.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 18/02/25.
//

import SwiftUI

struct TracingPuzzleView: View {
    @StateObject private var viewModel: TracingPuzzleViewModel
    @EnvironmentObject var router: NavigationRouter
    @State private var showSuccess: Bool = false
    
    init(viewModel: TracingPuzzleViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            GeometryReader { bgGeometry in
                Image(viewModel.levels[viewModel.currentLevel - 1].visualTheme.backgroundImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: bgGeometry.size.width, height: bgGeometry.size.height)
                    .clipped()
            }
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    CustomBackButton()
                        .padding(.leading, 20)
                    Spacer()
                }
                .padding(.top, 20)
                Spacer()
            }
            
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    
                    // Previously 0.7/1.4 - taller than the screen itself, so content
                    // near the top or bottom of the canvas (like level 3's moon)
                    // rendered above/below the visible area instead of on-screen.
                    TracingPuzzleDrawingView(viewModel: viewModel)
                        .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.85)
                    
                    Spacer()
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            
            SuccessOverlay(
                isVisible: showSuccess,
                onComplete: {
                    showSuccess = false
                    viewModel.finishSuccessAndReturnToMenu()
                }
            )
        }
        .onAppear {
            AudioPlayerManager.shared.playAudio(named: AudioConstants.dialogTrace, withExtension: AudioConstants.audioExtension)
        }
        .onDisappear {
            AudioPlayerManager.shared.stopBackgroundMusic()
            AudioPlayerManager.shared.playBackgroundMusic(named: AudioConstants.introMusic, withExtension: AudioConstants.audioExtension)
        }
        .blockInteractions(when: showSuccess)
        .onChange(of: viewModel.showSuccessOverlay) { shouldShow in
            if shouldShow {
                print("ShowSuccessOverlay changed to true - updating local state")
                withAnimation {
                    showSuccess = true
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: viewModel.shouldReturnToMenu) { shouldReturn in
            if shouldReturn {
                router.navigateToRoot()
                router.navigate(to: .menu)
            }
        }
        .onDisappear {
            if showSuccess {
                DispatchQueue.main.async {
                    router.navigateBack()
                    router.navigate(to: .tracingPuzzle)
                }
            }
        }
    }
}
