//
//  ContentView.swift
//  JigsawPuzzleImage
//
//  Created by Alvin Reyvaldo on 04/02/25.
//

import SwiftUI

struct JigsawPuzzleView: View {

    /// Shared coordinate space name for everything on this screen that reports
    /// or consumes a drag position - see the .coordinateSpace(name:) usage
    /// below for why this needs to be a single consistent space.
    static let jigsawCoordinateSpace = "jigsawPuzzleSpace"

    @EnvironmentObject var router: NavigationRouter
    @StateObject private var viewModel: JigsawPuzzleViewModel
    @State private var dragOffset: CGSize = .zero
    @State private var startLocation: CGPoint = .zero
    @State private var boardFrame: CGRect = .zero
    @State private var showShadowImage: Bool = true
    @State private var celebrationPoint: CGPoint?
    @State private var celebrationToken: Int = 0

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
                        JigsawProgressBadge(
                            placed: viewModel.placedPieces.count,
                            total: viewModel.rows * viewModel.cols
                        )
                        .padding(.trailing, 20)
                    }
                    .padding(.bottom, isPortrait ? 20 : 50)
                    
                    if isPortrait {
                        // Portrait layout (vertical stack). Board and workspace are
                        // NOT given fixed-height slots here - both already size
                        // themselves from pieceSize (JigsawBoardView and
                        // JigsawWorkspaceView each carry their own explicit
                        // .frame()). Forcing them into oversized fixed-percentage
                        // slots left a lot of slack once pieceSize shrank (the
                        // fixed heights were tuned for a larger piece size), spread
                        // across several gaps instead of one - a trailing Spacer()
                        // pulls the whole compact block toward the top instead.
                        VStack(spacing: 24) {
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

                            Spacer()
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

                if let celebrationPoint {
                    JigsawPieceCelebrationView()
                        .id(celebrationToken)
                        .position(celebrationPoint)
                }
            }
            // Everything that measures or reports a drag position (piece drag
            // gesture, board frame capture, dragged-piece rendering) shares this
            // one named space, scoped to this whole ZStack. Using .global for
            // some of those and this ZStack's own local space for others (e.g.
            // rendering via .position()) meant a piece could visually line up
            // with the right board cell while the coordinates actually used for
            // hit-testing were offset by the status bar/safe-area gap - so a
            // drop that looked correct on screen still failed.
            .coordinateSpace(name: Self.jigsawCoordinateSpace)
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
                AudioPlayerManager.shared.playBackgroundMusic(named: AudioConstants.introMusic, withExtension: AudioConstants.audioExtension)
            }
            .onChange(of: viewModel.currentImageIndex) { _ in
                showShadowImage = true
            }
            .onChange(of: viewModel.placedPieces.count) { newCount in
                // Fires a sparkle burst at the piece that was just placed correctly,
                // not only when the whole picture is finished - so every correct
                // placement gets its own moment of positive feedback.
                guard newCount > 0, let lastPiece = viewModel.placedPieces.last, boardFrame != .zero else { return }
                celebrationToken += 1
                celebrationPoint = CGPoint(
                    x: boardFrame.minX + CGFloat(lastPiece.col) * adaptivePieceSize + adaptivePieceSize / 2,
                    y: boardFrame.minY + CGFloat(lastPiece.row) * adaptivePieceSize + adaptivePieceSize / 2
                )
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
            // The landscape HStack lays out board (2x pieceSize wide) + a fixed
            // 60pt gap + tray (2.8x pieceSize wide), inside 60pt of padding on each
            // side - so the combined footprint is 4.8x pieceSize + 180. The old
            // width/5 formula never accounted for that footprint (it was tuned for
            // iPad's much wider landscape canvas), so on an iPhone in landscape the
            // required width exceeded what was actually available, overflowing the
            // tray outside its own container.
            let horizontalChrome: CGFloat = 180
            let hstackDivisor: CGFloat = 4.8
            let widthBasedSize = (geometry.size.width - horizontalChrome) / hstackDivisor

            // Same height-awareness as portrait: the back button row plus its
            // padding has to be reserved before the board/tray get whatever
            // vertical space remains.
            let verticalChrome: CGFloat = 150
            let heightBudget = geometry.size.height - verticalChrome
            let heightBasedSize = (heightBudget - JigsawWorkspaceView.chromeHeight) / 2

            adaptivePieceSize = max(70, min(widthBasedSize, heightBasedSize, 200))
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
