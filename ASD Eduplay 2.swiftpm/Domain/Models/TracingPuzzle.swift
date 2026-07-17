//
//  File.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 18/02/25.
//

import Foundation
import SwiftUI

struct TracingPuzzleLevel {
    let id: Int
    let startPoint: CGPoint
    let endPoint: CGPoint
    let visualTheme: TracingPuzzleTheme
    var isCompleted: Bool = false
}

struct TracingPuzzleTheme {
    let id: Int
    let themeName: String
    let startImage: String
    let isStartImageSystem: Bool
    let endImage: String
    let isEndImageSystem: Bool
    let pathColor: Color
    let backgroundColor: Color
    let backgroundImage: String  
    let animationDuration: Double
    let animationType: Animation
}
