import SwiftUI

@MainActor
final class MatchingPuzzleViewModel: ObservableObject {
    
    @Published var pieces: [MatchingPuzzle] = []
    @Published var currentTarget: String = ""
    @Published var matchCompleted: Bool = false
    @Published var shouldReturnToMenu: Bool = false
    @Published var showSuccessOverlay: Bool = false
    @Published private(set) var completedRounds: Int = 0
    
    
    
    private let matchingUseCase: MatchingPuzzleUseCase
    private let maxRounds = 5

    
    init(matchingUseCase: MatchingPuzzleUseCase) {
        self.matchingUseCase = matchingUseCase
        createNewPuzzle()
    }
    
    func handlePuzzleDrop(piece: MatchingPuzzle, dropLocation: CGPoint, targetFrame: CGRect) {
        let pieceFrame = CGRect(
            x: dropLocation.x - 40,
            y: dropLocation.y - 40,
            width: 80,
            height: 80
        )
        
        if targetFrame.intersects(pieceFrame) {
            if piece.imageName == currentTarget {
                if let index = pieces.firstIndex(where: { $0.id == piece.id }) {
                    withAnimation(.spring()) {
                        pieces[index].isMatched = true
                        pieces[index].isVisible = false
                    }
                    Haptic.shared.success()
                    matchCompleted = true
                    completedRounds += 1
                    checkRoundCompletion()
                    AudioPlayerManager.shared.playAudio(named: AudioConstants.correctAction, withExtension: AudioConstants.audioExtension)
                }
            } else {
                AudioPlayerManager.shared.playAudio(named: AudioConstants.incorrectAction, withExtension: AudioConstants.audioExtension)
                    Haptic.shared.error()
            }
        }
        
        if let index = pieces.firstIndex(where: { $0.id == piece.id }) {
            withAnimation(.spring()) {
                pieces[index].offSet = .zero
            }
        }
    }
    
    private func checkRoundCompletion() {
           if completedRounds >= maxRounds {               
               DispatchQueue.main.asyncAfter(deadline: .now() ) {
                   self.handlePuzzleCompletion()
               }
           } else {
               DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                   self.createNewPuzzle()
                   self.matchCompleted = false
                   AudioPlayerManager.shared.playAudio(
                       named: AudioConstants.roundComplete,
                       withExtension: AudioConstants.audioExtension
                   )

               }
           }
       }
    
    func handleDragChanged(_ piece: MatchingPuzzle, translation: CGSize) {
        if let index = pieces.firstIndex(where: { $0.id == piece.id }) {
            pieces[index].offSet = translation
        }
    }
    
    func createNewPuzzle() {
        let (newPieces, newTarget) = matchingUseCase.createMatchingPuzzle()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                self.pieces = newPieces
                self.currentTarget = newTarget
            }
        }
    }
    
    private func handlePuzzleCompletion() {
          withAnimation {
              showSuccessOverlay = true

          }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            AudioPlayerManager.shared.playAudio(
                named: AudioConstants.puzzleComplete,
                withExtension: AudioConstants.audioExtension
            )
        }
      }
    

    func finishSuccessAndReturnToMenu() {
        AudioPlayerManager.shared.stopBackgroundMusic()
            DispatchQueue.main.async {
                AudioPlayerManager.shared.playBackgroundMusic(
                               named: AudioConstants.introMusic,
                               withExtension: AudioConstants.audioExtension
                           )
                self.shouldReturnToMenu = true
            }
        }
}
