//
//  TracingPuzzleRepositoryImpl.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 18/02/25.
//

import Foundation
import SwiftUI

@MainActor
class TracingPuzzleRepositoryImpl: @preconcurrency TracingPuzzleRepository {
    private var levels: [TracingPuzzleLevel] = []
    private let totalLevels = 3
    
    init() {
        setupInitialLevels()
    }
    
    private func setupInitialLevels() {
        levels = (1...totalLevels).map { levelNum in
            let (startPoint, endPoint) = getLevelPoints(level: levelNum)
            return TracingPuzzleLevel(
                id: levelNum,
                startPoint: startPoint,
                endPoint: endPoint,
                visualTheme: getThemeForLevel(levelNum)
            )
        }
    }

    /// Returns start/end points as fractions (0...1) of the drawing view's own size,
    /// not absolute pixels, so the trace path stays correct across rotation and
    /// different iPad sizes instead of being fixed to the screen size at launch.
    private func getLevelPoints(level: Int) -> (CGPoint, CGPoint) {
        switch level {
        case 1:
            return (CGPoint(x: 0.1, y: 0.45), CGPoint(x: 0.9, y: 0.45))
        case 2:
            return (CGPoint(x: 0.1, y: 0.6), CGPoint(x: 0.9, y: 0.3))
        case 3:
            let centerX: CGFloat = 0.5
            return (CGPoint(x: centerX, y: 0.6), CGPoint(x: centerX, y: 0.3))
        default:
            return (CGPoint(x: 0.25, y: 0.5), CGPoint(x: 0.75, y: 0.5))
        }
    }
    
    private func getThemeForLevel(_ level: Int) -> TracingPuzzleTheme {
        switch level {
        case 1:
            return TracingPuzzleTheme(
                id: 1,
                themeName: "Road Trip",
                startImage: "car",
                isStartImageSystem: false,
                endImage: "houseDessert",
                isEndImageSystem: false,
                pathColor: .white,
                backgroundColor: .clear,
                backgroundImage: "backgroundCase1",
                animationDuration: 1.0,
                animationType: .easeInOut
            )
        case 2:
            return TracingPuzzleTheme(
                id: 2,
                themeName: "Ocean Voyage",
                startImage: "ship",
                isStartImageSystem: false,
                endImage: "island",
                isEndImageSystem: false,
                pathColor: .green,
                backgroundColor: .clear,
                backgroundImage: "backgroundCase2",
                animationDuration: 1.2,
                animationType: .easeInOut
            )
        case 3:
            return TracingPuzzleTheme(
                id: 3,
                themeName: "Space Journey",
                startImage: "rocket",
                isStartImageSystem: false,
                endImage: "moon",
                isEndImageSystem: false,
                pathColor: .purple.opacity(0.7),
                backgroundColor: .clear,
                backgroundImage: "backgroundCase3",
                animationDuration: 1.5,
                animationType: .easeInOut
            )
        default:
            return TracingPuzzleTheme(
                id: level,
                themeName: "Default",
                startImage: "star.fill",
                isStartImageSystem: true,
                endImage: "flag.fill",
                isEndImageSystem: true,
                pathColor: .gray,
                backgroundColor: .clear,
                backgroundImage: "default_background",
                animationDuration: 1.0,
                animationType: .easeInOut
            )
        }
    }

    func getLevels() -> [TracingPuzzleLevel] {
        return levels
    }
    
    func getTotalLevels() -> Int {
        return totalLevels
    }
    
    func updateLevelCompletion(level: Int, isCompleted: Bool) {
        if let index = levels.firstIndex(where: { $0.id == level }) {
            levels[index].isCompleted = isCompleted
        }
    }
}
