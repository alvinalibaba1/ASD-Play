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
                        progressBadge
                            .padding(.trailing, 20)
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
            .onChange(of: geometry.size) { _, newSize in
                viewModel.updateLayout(containerSize: newSize)
            }
            .onDisappear {
                AudioPlayerManager.shared.stopBackgroundMusic()
                AudioPlayerManager.shared.playBackgroundMusic(named: AudioConstants.introMusic, withExtension: AudioConstants.audioExtension)
            }
            .onChange(of: viewModel.isComplete) { _, isComplete in
                if isComplete && viewModel.currentRound == 5 && !isTransitioning {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showSuccessOverlay = true
                    }
                }
            }
            .onChange(of: viewModel.shouldReturnToMenu) { _, shouldReturn in
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
    
    private var progressBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.up.arrow.down.circle.fill")
                .font(.system(size: 14, weight: .semibold))
            Text("\(viewModel.currentRound)/5")
                .font(.system(size: 16, weight: .bold, design: .rounded))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color.green.opacity(0.85)))
        .shadow(radius: 4)
    }

    // Mirrors SortingPuzzleViewModel.pieceSpacing's formula
    // (min(width * 0.35, height * 0.45, cap)) so the bin/piece shapes stay
    // proportionally sized relative to the spacing between them instead of
    // overlapping (or clipping off the top of a short landscape screen) on one
    // axis while just tracking the other.
    private func workspaceView(for workspace: Workspace, containerSize: CGSize) -> some View {
        let size = min(containerSize.width * 0.35, containerSize.height * 0.45, 300)
        return ZStack {
            Circle()
                .fill(workspace.color.opacity(0.18))
                .frame(width: size, height: size)
            Circle()
                .strokeBorder(workspace.color, style: StrokeStyle(lineWidth: 6, dash: [12, 8]))
                .frame(width: size, height: size)
            Text(workspace.label)
                .font(.system(size: size * 0.14, weight: .bold, design: .rounded))
                .foregroundColor(workspace.color)
        }
        .position(workspace.position)
    }

    private func puzzlePieceView(for piece: SortingPuzzlePiece, containerSize: CGSize) -> some View {
        let size = min(containerSize.width * 0.35, containerSize.height * 0.45, 300) * (200.0 / 300.0)
        return Circle()
            .fill(piece.color)
            .overlay(Circle().stroke(Color.white, lineWidth: 4))
            .shadow(radius: 4)
            .frame(width: size, height: size)
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
            .animation(.spring(), value: piece.isPlaced)
            // The drag gesture has no VoiceOver equivalent. A VO user picks
            // which bin to place the piece in from its real actions (one per
            // bin) instead of dragging - the same color-matching information
            // a sighted user gets by comparing the piece's color to each
            // bin's, just spoken instead of seen.
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(colorLabel(for: piece)) piece\(piece.isPlaced ? ", placed" : "")")
            .accessibilityActions {
                if !piece.isPlaced {
                    ForEach(viewModel.workspaces, id: \.id) { workspace in
                        Button(workspace.label) {
                            viewModel.movePiece(piece, to: workspace.position, isDragging: false)
                        }
                    }
                }
            }
    }

    private func colorLabel(for piece: SortingPuzzlePiece) -> String {
        viewModel.workspaces.first(where: { $0.id == piece.targetWorkspaceId })?.label ?? "Colored"
    }
}
