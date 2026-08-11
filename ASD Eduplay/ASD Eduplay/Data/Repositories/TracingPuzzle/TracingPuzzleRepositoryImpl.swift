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
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        levels = (1...totalLevels).map { levelNum in
            let (startPoint, endPoint) = getLevelPoints(level: levelNum, screenWidth: screenWidth, screenHeight: screenHeight)
            return TracingPuzzleLevel(
                id: levelNum,
                startPoint: startPoint,
                endPoint: endPoint,
                visualTheme: getThemeForLevel(levelNum)
            )
        }
    }
    
    private func getLevelPoints(level: Int, screenWidth: CGFloat, screenHeight: CGFloat) -> (CGPoint, CGPoint) {
        switch level {
        case 1:
            return (CGPoint(x: screenWidth * 0.1, y: screenHeight * 0.45),
                    CGPoint(x: screenWidth * 0.9, y: screenHeight * 0.45))
        case 2:
            return (CGPoint(x: screenWidth * 0.1, y: screenHeight * 0.6),
                    CGPoint(x: screenWidth * 0.9, y: screenHeight * 0.3))
        case 3:
            let centerX = screenWidth * 0.5
                    return (CGPoint(x: centerX, y: screenHeight * 0.6),  
                            CGPoint(x: centerX, y: screenHeight * 0.3))
        default:
            return (CGPoint(x: screenWidth * 0.25, y: screenHeight * 0.5),
                    CGPoint(x: screenWidth * 0.75, y: screenHeight * 0.5))
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
