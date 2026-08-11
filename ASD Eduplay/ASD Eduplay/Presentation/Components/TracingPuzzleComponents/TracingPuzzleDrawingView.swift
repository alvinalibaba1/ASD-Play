//
//  SwiftUIView.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 18/02/25.
//

import SwiftUI

struct TracingPuzzleDrawingView: View {
    @ObservedObject var viewModel: TracingPuzzleViewModel
    
    @State private var currentPoint: CGPoint?
    @State private var pathPoints: [CGPoint] = []
    @State private var isTracing = false
    @State private var snapDistance: CGFloat = 30.0
    @State private var animatingImage: Bool = false
    @State private var animationPosition: CGPoint = .zero
    @State private var showTrace: Bool = true
    @State private var showDots: Bool = true
    @State private var animationPhase: Int = 0
    @State private var previousLevel: Int = 0
    
    private var currentLevel: TracingPuzzleLevel {
        viewModel.levels[viewModel.currentLevel - 1]
    }
    
    private var startConnectionPoint: CGPoint {
            if viewModel.currentLevel == 3 {
                return CGPoint(x: currentLevel.startPoint.x, y: currentLevel.startPoint.y)
            } else {
                return CGPoint(x: currentLevel.startPoint.x + 120, y: currentLevel.startPoint.y)
            }
        }

        private var endConnectionPoint: CGPoint {
            if viewModel.currentLevel == 3 {
                return CGPoint(x: currentLevel.endPoint.x, y: currentLevel.endPoint.y)
            } else {
                return CGPoint(x: currentLevel.endPoint.x - 120, y: currentLevel.endPoint.y)
            }
        }
    
    
    
    var body: some View {
            GeometryReader { geometry in
                ZStack {
                    if showTrace {
                        Path { path in
                            path.move(to: startConnectionPoint)
                            path.addLine(to: endConnectionPoint)
                        }
                        .stroke(currentLevel.visualTheme.pathColor.opacity(0.5),
                                style: StrokeStyle(lineWidth: 45, lineCap: .round))
                        
                        Path { path in
                            if let firstPoint = pathPoints.first {
                                path.move(to: firstPoint)
                                for point in pathPoints.dropFirst() {
                                    path.addLine(to: point)
                                }
                                if let current = currentPoint {
                                    path.addLine(to: current)
                                }
                            }
                        }
                        .stroke(currentLevel.visualTheme.pathColor,
                                style: StrokeStyle(lineWidth: 30, lineCap: .round))
                    }
                    
                    if showDots {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 50, height: 50)
                            .shadow(radius: 3)
                            .position(startConnectionPoint)
                        
                        Circle()
                            .fill(Color.red)
                            .frame(width: 50, height: 50)
                            .shadow(radius: 3)
                            .position(endConnectionPoint)
                    }
                    
                    if viewModel.currentLevel == 3 {
                        
                        if currentLevel.visualTheme.isEndImageSystem {
                            Image(systemName: currentLevel.visualTheme.endImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                                .foregroundColor(.white)
                                .position(CGPoint(x: currentLevel.endPoint.x, y: currentLevel.endPoint.y - 100))
                                .opacity(0.8)
                        } else {
                            Image(currentLevel.visualTheme.endImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                                .position(CGPoint(x: currentLevel.endPoint.x, y: currentLevel.endPoint.y - 150))
                        }
                        
                        if !animatingImage {
                            if currentLevel.visualTheme.isStartImageSystem {
                                Image(systemName: currentLevel.visualTheme.startImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .foregroundColor(.white)
                                    .position(CGPoint(x: currentLevel.startPoint.x, y: currentLevel.startPoint.y + 100))
                            } else {
                                Image(currentLevel.visualTheme.startImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .position(CGPoint(x: currentLevel.startPoint.x, y: currentLevel.startPoint.y + 100))
                            }
                        } else {
                            if currentLevel.visualTheme.isStartImageSystem {
                                Image(systemName: currentLevel.visualTheme.startImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .foregroundColor(.white)
                                    .position(animationPosition)
                            } else {
                                Image(currentLevel.visualTheme.startImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .position(animationPosition)
                            }
                        }
                    } else {
                        
                        if currentLevel.visualTheme.isEndImageSystem {
                            Image(systemName: currentLevel.visualTheme.endImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 400, height: 400)
                                .foregroundColor(.black)
                                .position(CGPoint(x: currentLevel.endPoint.x + 40, y: currentLevel.endPoint.y))
                                .opacity(0.5)
                        } else {
                            Image(currentLevel.visualTheme.endImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                                .position(CGPoint(x: currentLevel.endPoint.x + 100, y: currentLevel.endPoint.y + -50))
                            
                        }
                        
                        if !animatingImage {
                            if currentLevel.visualTheme.isStartImageSystem {
                                Image(systemName: currentLevel.visualTheme.startImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .foregroundColor(.black)
                                    .position(CGPoint(x: currentLevel.startPoint.x - 40, y: currentLevel.startPoint.y))
                            } else {
                                Image(currentLevel.visualTheme.startImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .position(CGPoint(x: currentLevel.startPoint.x - 40, y: currentLevel.startPoint.y))
                            }
                        } else {
                            if currentLevel.visualTheme.isStartImageSystem {
                                Image(systemName: currentLevel.visualTheme.startImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .foregroundColor(.black)
                                    .position(animationPosition)
                            } else {
                                Image(currentLevel.visualTheme.startImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .position(animationPosition)
                            }
                        }
                    }
                }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if animationPhase == 0 {
                            handleDrag(value: value, in: geometry)
                        }
                    }
                    .onEnded { _ in
                        if animationPhase == 0 {
                            handleDragEnd()
                        }
                    }
            )
            .onAppear {
                previousLevel = viewModel.currentLevel
                resetAnimationState()
            }
            .onChange(of: viewModel.currentLevel) { newLevel in
                if previousLevel != newLevel {
                    resetAnimationState()
                    previousLevel = newLevel
                }
            }
        }
    }
    
    private func resetAnimationState() {
        withAnimation(.none) {
            pathPoints = []
            currentPoint = nil
            isTracing = false
            animatingImage = false
            showTrace = true
            showDots = true
            animationPhase = 0
        }
    }
    
    private func handleDrag(value: DragGesture.Value, in geometry: GeometryProxy) {
        let point = value.location
        
        let snapDistance: CGFloat = 75.0
        
        if !isTracing {
            let distanceToStart = distance(from: point, to: startConnectionPoint)
            if distanceToStart <= snapDistance {
                isTracing = true
                pathPoints = [startConnectionPoint]
                currentPoint = startConnectionPoint
            }
            return
        }
            
        let idealPoint = nearestPointOnLine(
            from: startConnectionPoint,
            to: endConnectionPoint,
            to: point
        )
        
        let distanceToIdeal = distance(from: point, to: idealPoint)
        let snappedPoint = distanceToIdeal <= snapDistance ? idealPoint : point
        currentPoint = snappedPoint
        pathPoints.append(snappedPoint)
        let distanceToEnd = distance(from: snappedPoint, to: endConnectionPoint)
        if distanceToEnd <= snapDistance {
            completeTracing()
            AudioPlayerManager.shared.playAudio(named: AudioConstants.correctAction, withExtension: AudioConstants.audioExtension)
        }
    }
    
    private func handleDragEnd() {
        isTracing = false
        currentPoint = nil
        if !currentLevel.isCompleted {
            pathPoints = []
        }
    }
    
    private func completeTracing() {
        pathPoints.append(endConnectionPoint)
        
        startAnimationSequence()
    }
    
    private func startAnimationSequence() {
            animationPhase = 1
            
            withAnimation(.easeOut(duration: 0.5)) {
                showTrace = false
                showDots = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                animationPhase = 2
                animatingImage = true
                
                if viewModel.currentLevel == 3 {
                    animationPosition = CGPoint(x: currentLevel.startPoint.x, y: currentLevel.startPoint.y + 100)
                } else {
                    animationPosition = CGPoint(x: currentLevel.startPoint.x - 40, y: currentLevel.startPoint.y)
                }
                
                withAnimation(.easeInOut(duration: 1.5)) {
                    if viewModel.currentLevel == 3 {
                        animationPosition = CGPoint(x: currentLevel.endPoint.x, y: currentLevel.endPoint.y - 100)
                    } else {
                        animationPosition = CGPoint(x: currentLevel.endPoint.x - 140, y: currentLevel.endPoint.y)
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    viewModel.completeLevel()
                }
            }
        }
    
    private func distance(from p1: CGPoint, to p2: CGPoint) -> CGFloat {
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        return sqrt(dx * dx + dy * dy)
    }
    
    private func nearestPointOnLine(from start: CGPoint, to end: CGPoint, to point: CGPoint) -> CGPoint {
        let dx = end.x - start.x
        let dy = end.y - start.y
        
        if dx == 0 && dy == 0 {
            return start
        }
        
        let t = ((point.x - start.x) * dx + (point.y - start.y) * dy) / (dx * dx + dy * dy)
        
        if t < 0 {
            return start
        } else if t > 1 {
            return end
        }
        
        return CGPoint(
            x: start.x + t * dx,
            y: start.y + t * dy
        )
    }
}
