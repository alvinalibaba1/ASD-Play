//
//  File.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 14/02/25.
//

import Foundation

struct MatchingPuzzle: Identifiable, Equatable {
    let id = UUID()
    let imageName: String
    var offSet: CGSize = .zero
    var isMatched: Bool = false
    var isVisible: Bool = true
}
