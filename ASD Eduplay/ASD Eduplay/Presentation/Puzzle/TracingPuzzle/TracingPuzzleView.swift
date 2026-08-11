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
            Image(viewModel.levels[viewModel.currentLevel - 1].visualTheme.backgroundImage)
                .resizable()
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
                    
                    TracingPuzzleDrawingView(viewModel: viewModel)
                        .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 1.4)
                    
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
            AudioPlayerManager.shared.playAudio(named: AudioConstants.introMusic, withExtension: AudioConstants.audioExtension)
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
