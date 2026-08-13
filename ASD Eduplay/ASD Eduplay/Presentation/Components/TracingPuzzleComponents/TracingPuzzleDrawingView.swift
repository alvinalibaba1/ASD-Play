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

    /// Converts a start/end point stored as a fraction (0...1) into an actual pixel
    /// position within `size`, so points stay correct across rotation instead of
    /// being tied to whatever screen size the level was first computed on.
    private func point(for fraction: CGPoint, in size: CGSize, offset: CGPoint = .zero) -> CGPoint {
        CGPoint(x: fraction.x * size.width + offset.x, y: fraction.y * size.height + offset.y)
    }

    private func startConnectionPoint(in size: CGSize) -> CGPoint {
        if viewModel.currentLevel == 3 {
            return point(for: currentLevel.startPoint, in: size)
        } else {
            return point(for: currentLevel.startPoint, in: size, offset: CGPoint(x: 120, y: 0))
        }
    }

    private func endConnectionPoint(in size: CGSize) -> CGPoint {
        if viewModel.currentLevel == 3 {
            return point(for: currentLevel.endPoint, in: size)
        } else {
            return point(for: currentLevel.endPoint, in: size, offset: CGPoint(x: -120, y: 0))
        }
    }

    var body: some View {
            GeometryReader { geometry in
                ZStack {
                    if showTrace {
                        Path { path in
                            path.move(to: startConnectionPoint(in: geometry.size))
                            path.addLine(to: endConnectionPoint(in: geometry.size))
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
                            .position(startConnectionPoint(in: geometry.size))

                        Circle()
                            .fill(Color.red)
                            .frame(width: 50, height: 50)
                            .shadow(radius: 3)
                            .position(endConnectionPoint(in: geometry.size))
                    }

                    if viewModel.currentLevel == 3 {

                        if currentLevel.visualTheme.isEndImageSystem {
                            Image(systemName: currentLevel.visualTheme.endImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                                .foregroundColor(.white)
                                .position(point(for: currentLevel.endPoint, in: geometry.size, offset: CGPoint(x: 0, y: -100)))
                                .opacity(0.8)
                        } else {
                            Image(currentLevel.visualTheme.endImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                                .position(point(for: currentLevel.endPoint, in: geometry.size, offset: CGPoint(x: 0, y: -150)))
                        }

                        if !animatingImage {
                            if currentLevel.visualTheme.isStartImageSystem {
                                Image(systemName: currentLevel.visualTheme.startImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .foregroundColor(.white)
                                    .position(point(for: currentLevel.startPoint, in: geometry.size, offset: CGPoint(x: 0, y: 100)))
                            } else {
                                Image(currentLevel.visualTheme.startImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .position(point(for: currentLevel.startPoint, in: geometry.size, offset: CGPoint(x: 0, y: 100)))
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
                                .position(point(for: currentLevel.endPoint, in: geometry.size, offset: CGPoint(x: 40, y: 0)))
                                .opacity(0.5)
                        } else {
                            Image(currentLevel.visualTheme.endImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                                .position(point(for: currentLevel.endPoint, in: geometry.size, offset: CGPoint(x: 100, y: -50)))

                        }

                        if !animatingImage {
                            if currentLevel.visualTheme.isStartImageSystem {
                                Image(systemName: currentLevel.visualTheme.startImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .foregroundColor(.black)
                                    .position(point(for: currentLevel.startPoint, in: geometry.size, offset: CGPoint(x: -40, y: 0)))
                            } else {
                                Image(currentLevel.visualTheme.startImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .position(point(for: currentLevel.startPoint, in: geometry.size, offset: CGPoint(x: -40, y: 0)))
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
        let size = geometry.size

        let snapDistance: CGFloat = 75.0

        if !isTracing {
            let distanceToStart = distance(from: point, to: startConnectionPoint(in: size))
            if distanceToStart <= snapDistance {
                isTracing = true
                pathPoints = [startConnectionPoint(in: size)]
                currentPoint = startConnectionPoint(in: size)
            }
            return
        }

        let idealPoint = nearestPointOnLine(
            from: startConnectionPoint(in: size),
            to: endConnectionPoint(in: size),
            to: point
        )

        let distanceToIdeal = distance(from: point, to: idealPoint)
        let snappedPoint = distanceToIdeal <= snapDistance ? idealPoint : point
        currentPoint = snappedPoint
        pathPoints.append(snappedPoint)
        let distanceToEnd = distance(from: snappedPoint, to: endConnectionPoint(in: size))
        if distanceToEnd <= snapDistance {
            completeTracing(in: size)
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

    private func completeTracing(in size: CGSize) {
        pathPoints.append(endConnectionPoint(in: size))

        startAnimationSequence(in: size)
    }

    private func startAnimationSequence(in size: CGSize) {
            animationPhase = 1

            withAnimation(.easeOut(duration: 0.5)) {
                showTrace = false
                showDots = false
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                animationPhase = 2
                animatingImage = true

                if viewModel.currentLevel == 3 {
                    animationPosition = point(for: currentLevel.startPoint, in: size, offset: CGPoint(x: 0, y: 100))
                } else {
                    animationPosition = point(for: currentLevel.startPoint, in: size, offset: CGPoint(x: -40, y: 0))
                }

                withAnimation(.easeInOut(duration: 1.5)) {
                    if viewModel.currentLevel == 3 {
                        animationPosition = point(for: currentLevel.endPoint, in: size, offset: CGPoint(x: 0, y: -100))
                    } else {
                        animationPosition = point(for: currentLevel.endPoint, in: size, offset: CGPoint(x: -140, y: 0))
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
