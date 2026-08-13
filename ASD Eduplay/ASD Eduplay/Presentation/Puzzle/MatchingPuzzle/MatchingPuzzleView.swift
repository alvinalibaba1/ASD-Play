import SwiftUI

struct MatchingPuzzleView: View {
    @EnvironmentObject var router: NavigationRouter
    @StateObject private var viewModel: MatchingPuzzleViewModel
    @State private var targetPosition: CGRect = .zero
    @State private var isDragging: Bool = false
    @State private var showTargetAnimation: Bool = true
    @State private var completedRounds: Int = 0
    @State private var showSuccess: Bool = false
    
    private let maxRounds = 5
    
    init(viewModel: MatchingPuzzleViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                GeometryReader { bgGeometry in
                    Image("backgroundMatching")
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
                    Spacer()
                    
                    if showTargetAnimation {
                        plateTargetArea(width: geometry.size.width)
                            .transition(.opacity.combined(with: .scale))
                            .frame(height: geometry.size.height * 0.5)
                            .padding(.top, 60)
                    }
                    
                    Spacer()
                    
                    VStack {
                        // Solved from a fixed, comfortable gap rather than a fraction of
                        // circleDiameter - that made the gap shrink to almost nothing
                        // alongside the circles on narrow screens, reading as the 4
                        // pieces touching each other. Capped at the original iPad size.
                        let itemSpacing: CGFloat = 16
                        let horizontalPadding: CGFloat = 20
                        let availableWidth = geometry.size.width - horizontalPadding * 2
                        let circleDiameter = min((availableWidth - itemSpacing * 3) / 4, 150)
                        let imageDiameter = circleDiameter * (110.0 / 150.0)

                        HStack(spacing: itemSpacing) {
                            ForEach(viewModel.pieces) { piece in
                                if piece.isVisible {
                                    Image(piece.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: imageDiameter, height: imageDiameter)
                                        .opacity(piece.isMatched ? 0.5 : 1.0)
                                        .offset(piece.offSet)
                                        .shadow(radius: 8)
                                        .background(
                                            Circle()
                                                .fill(Color.white.opacity(0.95))
                                                .shadow(radius: 8)
                                                .frame(width: circleDiameter, height: circleDiameter)
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(Color.blue.opacity(0.3), lineWidth: 3)
                                                .frame(width: circleDiameter, height: circleDiameter)
                                        )
                                        .gesture(
                                            DragGesture(coordinateSpace: .global)
                                                .onChanged { value in
                                                    guard !piece.isMatched && !showSuccess else { return }
                                                    isDragging = true
                                                    viewModel.handleDragChanged(piece, translation: value.translation)
                                                }
                                                .onEnded { value in
                                                    guard !showSuccess else { return }
                                                    isDragging = false
                                                    let piecePosition = value.location
                                                    viewModel.handlePuzzleDrop(
                                                        piece: piece,
                                                        dropLocation: piecePosition,
                                                        targetFrame: targetPosition
                                                    )
                                                }
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120)
                    }
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
                AudioPlayerManager.shared.playAudio(named: AudioConstants.dialogMatching, withExtension: AudioConstants.audioExtension)
            }
            .onDisappear {
                AudioPlayerManager.shared.stopBackgroundMusic()
                AudioPlayerManager.shared.playBackgroundMusic(named: AudioConstants.introMusic, withExtension: AudioConstants.audioExtension)
            }
            .onChange(of: viewModel.matchCompleted) { completed in
                if completed {
                    handleSuccessfulMatch()
                }
            }
            .onChange(of: viewModel.shouldReturnToMenu) { shouldReturn in
                if shouldReturn {
                    router.navigateToRoot()
                    router.navigate(to: .menu)
                }
            }
            .blockInteractions(when: showSuccess)
            .onDisappear {
                if showSuccess {
                    DispatchQueue.main.async {
                        router.navigateBack()
                        router.navigate(to: .matchingPuzzle)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)

        }
    }
    
    private func plateTargetArea(width: CGFloat) -> some View {
        let plateSize = min(width * 0.4, 200)

        return ZStack {
            VStack(spacing: 20) {
                    Image(viewModel.currentTarget)
                        .resizable()
                        .scaledToFit()
                        .frame(width: plateSize, height: plateSize)
                        .shadow(color: Color.white.opacity(0.6), radius: 10)
                        .padding(.bottom, 50)
                
                Spacer()
            }
        }
        .background(GeometryReader { geometry -> Color in
            DispatchQueue.main.async {
                targetPosition = geometry.frame(in: .global)
            }
            return Color.clear
        })
        .scaleEffect(isDragging ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: isDragging)
    }
    
    private func handleSuccessfulMatch() {
        completedRounds += 1
        playSuccessSound()
            
        withAnimation(.easeInOut(duration: 1.5)) {
            showTargetAnimation = false
        }
        
        if completedRounds >= maxRounds {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    showSuccess = true
                }
            }
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            viewModel.matchCompleted = false
            
            withAnimation(.easeInOut(duration: 1.5)) {
                showTargetAnimation = true
            }
        }
    }
    
    private func playSuccessSound() {
        Haptic.shared.correct()
    }
}
