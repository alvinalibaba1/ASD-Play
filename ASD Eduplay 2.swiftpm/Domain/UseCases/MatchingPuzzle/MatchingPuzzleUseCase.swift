import Foundation

protocol MatchingPuzzleUseCase {
    func createMatchingPuzzle() -> ([MatchingPuzzle], String)
    func validateMatch(piece: MatchingPuzzle, target: String) -> Bool
}
