//
//  SwiftUIView.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 16/02/25.
//

import SwiftUI

struct SortingPuzzleView: View {
    @EnvironmentObject var router: NavigationRouter
    @StateObject private var viewModel: SortingPuzzleViewModel
    @State private var elementsVisible = false
    @State private var showSuccessOverlay = false
    @State private var isTransitioning = false
    
    init(viewModel: SortingPuzzleViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                GeometryReader { bgGeometry in
                    Image("backgroundSorting")
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

                VStack {
                    ZStack {
                        ForEach(viewModel.workspaces, id: \.id) { workspace in
                            workspaceView(for: workspace, containerWidth: geometry.size.width)
                                .opacity(elementsVisible ? 1 : 0)
                                .scaleEffect(elementsVisible ? 1 : 0.5)
                        }

                        ForEach(viewModel.puzzlePieces, id: \.id) { piece in
                            puzzlePieceView(for: piece, containerWidth: geometry.size.width)
                                .opacity(elementsVisible ? 1 : 0)
                                .scaleEffect(elementsVisible ? 1 : 0.5)
                        }
                    }
                    .allowsHitTesting(!isTransitioning)
                }

                SuccessOverlay(
                    isVisible: showSuccessOverlay,
                    onComplete: {
                        showSuccessOverlay = false
                        viewModel.finishSuccessAndReturnToMenu()
                    }
                )
            }
            .onAppear {
                viewModel.updateLayout(containerSize: geometry.size)
                withAnimation(.easeIn(duration: 1.0)) {
                    elementsVisible = true
                    AudioPlayerManager.shared.playAudio(named: AudioConstants.dialogSorting, withExtension: AudioConstants.audioExtension)
                }
            }
            .onChange(of: geometry.size) { newSize in
                viewModel.updateLayout(containerSize: newSize)
            }
            .onDisappear {
                AudioPlayerManager.shared.stopBackgroundMusic()
                AudioPlayerManager.shared.playAudio(named: AudioConstants.introMusic, withExtension: AudioConstants.audioExtension)
            }
            .onChange(of: viewModel.isComplete) { isComplete in
                if isComplete && viewModel.currentRound == 5 && !isTransitioning {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showSuccessOverlay = true
                    }
                }
            }
            .onChange(of: viewModel.shouldReturnToMenu) { shouldReturn in
                if shouldReturn {
                    router.navigateToRoot()
                    router.navigate(to: .menu)
                }
            }
            .blockInteractions(when: showSuccessOverlay)
            .gesture(
                showSuccessOverlay ?
                DragGesture().onChanged { _ in } :
                nil
            )
            .navigationBarBackButtonHidden(showSuccessOverlay)
            .onDisappear {
                if showSuccessOverlay {
                    DispatchQueue.main.async {
                        router.navigateBack()
                        router.navigate(to: .sortingPuzzle)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private func proceedToNextRound() {
        guard !isTransitioning else { return }
        isTransitioning = true
        
        withAnimation(.easeOut(duration: 0.5)) {
            elementsVisible = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            viewModel.nextRound()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeIn(duration: 1.0)) {
                    elementsVisible = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    isTransitioning = false
                }
            }
        }
    }
    
    private func resetGame() {
        guard !isTransitioning else { return }
        isTransitioning = true
        showSuccessOverlay = false
        
        withAnimation(.easeOut(duration: 0.5)) {
            elementsVisible = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            viewModel.resetGame()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeIn(duration: 1.0)) {
                    elementsVisible = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    isTransitioning = false
                }
            }
        }
    }
    
    // Mirrors SortingPuzzleViewModel.pieceSpacing's formula (min(width * 0.35, cap))
    // so piece/workspace art stays proportionally sized relative to the spacing
    // between them instead of overlapping on a narrow screen or looking tiny
    // against the gap on a wide one.
    private func workspaceView(for workspace: Workspace, containerWidth: CGFloat) -> some View {
        let size = min(containerWidth * 0.35, 300)
        return VStack {
            ZStack {
                Image(workspace.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
            }
            .position(workspace.position)
        }
    }

    private func puzzlePieceView(for piece: CorrectPuzzle, containerWidth: CGFloat) -> some View {
        let size = min(containerWidth * 0.35, 300) * (200.0 / 300.0)
        return VStack {
            ZStack {
                Image(piece.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
            }
            .position(piece.currentPosition)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        viewModel.movePiece(piece, to: value.location, isDragging: true)
                    }
                    .onEnded { value in
                        viewModel.movePiece(piece, to: value.location, isDragging: false)
                    }
            )
            .disabled(isTransitioning)
        }
        .animation(.spring(), value: piece.isPlaced)
    }
}
