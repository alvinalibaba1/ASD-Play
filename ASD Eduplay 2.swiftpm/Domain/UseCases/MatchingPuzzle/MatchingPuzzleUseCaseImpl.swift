//
//  File.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 14/02/25.
//

import Foundation

final class MatchingPuzzleUseCaseImpl: MatchingPuzzleUseCase {
    
    private let availableItems = ["apple", "banana", "orange", "grape", "cherry", "pumpkin", "mango", "blueberry", "strawberry", "watermelon"]
    
    func createMatchingPuzzle() -> ([MatchingPuzzle], String) {
        var pieces = availableItems.shuffled()
            .prefix(4)
            .map { MatchingPuzzle(imageName: $0) }
        
        let target = availableItems.randomElement()!
        
        if !pieces.contains(where: { $0.imageName == target }) {
            pieces[Int.random(in: 0..<pieces.count)] = MatchingPuzzle(imageName: target)
        }
        
        return (Array(pieces), target)
    }
    
    func validateMatch(piece: MatchingPuzzle, target: String) -> Bool {
        return piece.imageName == target
    }
}
