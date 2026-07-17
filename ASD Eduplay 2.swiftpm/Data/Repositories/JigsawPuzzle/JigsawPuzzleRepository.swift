//
//  File.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 19/02/25.
//

import Foundation

protocol JigsawPuzzleRepository {
    func getImageNames() -> [String]
    func getCurrentImageIndex() -> Int
    func updateImageIndex(_ index: Int)
    func resetImageIndex()
    func getTotalImageCount() -> Int
}
