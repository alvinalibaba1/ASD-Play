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
                            workspaceView(for: workspace, containerSize: geometry.size)
                                .opacity(elementsVisible ? 1 : 0)
                                .scaleEffect(elementsVisible ? 1 : 0.5)
                        }

                        ForEach(viewModel.puzzlePieces, id: \.id) { piece in
                            puzzlePieceView(for: piece, containerSize: geometry.size)
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
                AudioPlayerManager.shared.playBackgroundMusic(named: AudioConstants.introMusic, withExtension: AudioConstants.audioExtension)
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
    
    // Mirrors SortingPuzzleViewModel.pieceSpacing's formula
    // (min(width * 0.35, height * 0.45, cap)) so piece/workspace art stays
    // proportionally sized relative to the spacing between them instead of
    // overlapping (or clipping off the top of a short landscape screen) on one
    // axis while just tracking the other.
    private func workspaceView(for workspace: Workspace, containerSize: CGSize) -> some View {
        let size = min(containerSize.width * 0.35, containerSize.height * 0.45, 300)
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

    private func puzzlePieceView(for piece: SortingPuzzlePiece, containerSize: CGSize) -> some View {
        let size = min(containerSize.width * 0.35, containerSize.height * 0.45, 300) * (200.0 / 300.0)
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
