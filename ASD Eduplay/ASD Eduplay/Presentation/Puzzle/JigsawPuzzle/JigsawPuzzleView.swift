//
//  ContentView.swift
//  JigsawPuzzleImage
//
//  Created by Alvin Reyvaldo on 04/02/25.
//

import SwiftUI

struct JigsawPuzzleView: View {
    
    @EnvironmentObject var router: NavigationRouter
    @StateObject private var viewModel: JigsawPuzzleViewModel
    @State private var dragOffset: CGSize = .zero
    @State private var startLocation: CGPoint = .zero
    @State private var boardFrame: CGRect = .zero
    @State private var showShadowImage: Bool = true
    
    // Adaptive piece size based on orientation and screen size
    @State private var adaptivePieceSize: CGFloat = 200
    
    private var disableInteractions: Bool {
        return viewModel.isCompleted || viewModel.showSuccessOverlay
    }
    
    init(viewModel: JigsawPuzzleViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let isPortrait = geometry.size.height > geometry.size.width
            
            ZStack {
                GeometryReader { bgGeometry in
                    Image("backgroundJigsaw")
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
                    .padding(.bottom, isPortrait ? 20 : 50)
                    
                    if isPortrait {
                        // Portrait layout (vertical stack)
                        VStack(spacing: 30) {
                            JigsawBoardView(
                                viewModel: viewModel,
                                pieceSize: adaptivePieceSize,
                                showShadowImage: showShadowImage,
                                boardFrameUpdated: { newFrame in
                                    boardFrame = newFrame
                                }
                            )
                            .frame(height: geometry.size.height * 0.38)

                            JigsawWorkspaceView(
                                viewModel: viewModel,
                                pieceSize: adaptivePieceSize,
                                disableInteractions: disableInteractions,
                                onDragChanged: handleDragChanged,
                                onDragEnded: handleDragEnded
                            )
                            .frame(height: geometry.size.height * 0.45)
                        }
                        .padding(.horizontal, 20)
                    } else {
                        // Landscape layout (horizontal stack)
                        HStack(spacing: 60) {
                            JigsawBoardView(
                                viewModel: viewModel,
                                pieceSize: adaptivePieceSize,
                                showShadowImage: showShadowImage,
                                boardFrameUpdated: { newFrame in
                                    boardFrame = newFrame
                                }
                            )
                            
                            JigsawWorkspaceView(
                                viewModel: viewModel,
                                pieceSize: adaptivePieceSize,
                                disableInteractions: disableInteractions,
                                onDragChanged: handleDragChanged,
                                onDragEnded: handleDragEnded
                            )
                        }
                        .padding(.horizontal, 60)
                    }
                }
                
                JigsawDraggedPieceView(
                    viewModel: viewModel,
                    pieceSize: adaptivePieceSize,
                    startLocation: startLocation,
                    dragOffset: dragOffset
                )
                
                JigsawCompletionView(
                    viewModel: viewModel,
                    onComplete: {
                        viewModel.finishSuccessAndReturnToMenu()
                    }
                )
            }
            .onAppear {
                showShadowImage = true
                // Set adaptive piece size based on screen dimensions
                calculateAdaptivePieceSize(geometry: geometry)
                AudioPlayerManager.shared.playAudio(named: AudioConstants.dialogJigsaw, withExtension: AudioConstants.audioExtension)
            }
            .onChange(of: geometry.size) { newSize in
                // Recalculate piece size when orientation changes
                calculateAdaptivePieceSize(geometry: geometry)
            }
            .onDisappear {
                viewModel.resetGame()
                AudioPlayerManager.shared.stopBackgroundMusic()
                AudioPlayerManager.shared.playAudio(named: AudioConstants.introMusic, withExtension: AudioConstants.audioExtension)
            }
            .onChange(of: viewModel.currentImageIndex) { _ in
                showShadowImage = true
            }
        }
        .blockInteractions(when: viewModel.showSuccessOverlay)
        .gesture(
            viewModel.showSuccessOverlay ?
            DragGesture().onChanged { _ in } :
            nil
        )
        .navigationBarBackButtonHidden(viewModel.showSuccessOverlay)
        .onChange(of: viewModel.shouldReturnToMenu) { shouldReturn in
            if shouldReturn {
                router.navigateToRoot()
                router.navigate(to: .menu)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // Calculate appropriate piece size based on screen dimensions and orientation
    private func calculateAdaptivePieceSize(geometry: GeometryProxy) {
        let isPortrait = geometry.size.height > geometry.size.width
        if isPortrait {
            // /4 rather than /3: the tray is 2.8x this value wide, so /3 made it
            // span nearly the full iPhone screen edge-to-edge. /4 keeps pieces well
            // above the 44pt minimum touch target while leaving real margins.
            let widthBasedSize = geometry.size.width / 4

            // JigsawWorkspaceView's own fixed chrome (header + padding + the gap
            // between its two rows - see JigsawWorkspaceView.chromeHeight) has to be
            // reserved from its allotted height before splitting the rest across 2
            // rows. Without this, piece size was picked from width alone and could
            // be too tall to fit, forcing the tray to scroll to see every piece.
            let workspaceHeight = geometry.size.height * 0.45
            let heightBasedSize = (workspaceHeight - JigsawWorkspaceView.chromeHeight) / 2

            adaptivePieceSize = max(70, min(widthBasedSize, heightBasedSize, 150))
        } else {
            // Original piece size for landscape
            adaptivePieceSize = min(geometry.size.width / 5, 200)
        }
    }
    
    private func handleDragChanged(value: DragGesture.Value, piece: PuzzlePiece) {
        withAnimation(.none) {
            if viewModel.draggedPiece == nil {
                viewModel.draggedPiece = piece
                startLocation = value.startLocation
            }
            if viewModel.draggedPiece?.id == piece.id {
                dragOffset = value.translation
            }
        }
    }
    
    private func handleDragEnded(value: DragGesture.Value) {
        withAnimation(.none) {
            dragOffset = .zero
        }
        
        guard viewModel.draggedPiece != nil else { return }
        
        DispatchQueue.main.async {
            viewModel.handlePieceDrop(
                dropPoint: value.location,
                boardFrame: boardFrame,
                pieceSize: adaptivePieceSize
            )
        }
    }
}
