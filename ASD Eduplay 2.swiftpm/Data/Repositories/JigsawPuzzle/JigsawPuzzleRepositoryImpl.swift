//
//  File.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 19/02/25.
//

import Foundation

class JigsawPuzzleRepositoryImpl: JigsawPuzzleRepository {
    private var currentImageIndex: Int = 0
    
    private let imageNames: [String] = ["panda", "pig", "dog", "cat", "bird"]
    
    func getImageNames() -> [String] {
        return imageNames
    }
    
    func getCurrentImageIndex() -> Int {
        return currentImageIndex
    }
    
    func updateImageIndex(_ index: Int) {
        currentImageIndex = index % imageNames.count
    }
    
    func resetImageIndex() {
        currentImageIndex = 0
    }
    
    func getTotalImageCount() -> Int {
        return imageNames.count
    }
}
