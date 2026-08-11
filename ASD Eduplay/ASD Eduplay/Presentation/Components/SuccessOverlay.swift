//
//  SwiftUIView.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 19/02/25.
//
import SwiftUI

struct SuccessOverlay: View {
    let isVisible: Bool
    let onComplete: () -> Void

    @EnvironmentObject var settings: SensorySettings
    @State private var showStars = false
    @State private var showText = false
    
    let starCount = 50
    @State private var starScales: [CGFloat]
    @State private var starPositions: [CGPoint]
    @State private var starAngles: [Double]
    @State private var starColors: [Color]
    
    init(isVisible: Bool, onComplete: @escaping () -> Void) {
        self.isVisible = isVisible
        self.onComplete = onComplete
        
        var initialStarScales: [CGFloat] = []
        var initialStarPositions: [CGPoint] = []
        var initialStarAngles: [Double] = []
        var initialStarColors: [Color] = []
        
        let screenWidth = UIScreen.main.bounds.width
        let starColorOptions: [Color] = [.yellow, Color(hex: "FFD700"), Color(hex: "FFDF00"), Color(hex: "FFC125")]
        
        for _ in 0..<starCount {
            initialStarScales.append(CGFloat.random(in: 0.3...1.2))
            initialStarPositions.append(CGPoint(
                x: CGFloat.random(in: -20...screenWidth + 20),
                y: CGFloat.random(in: -200...0)
            ))
            initialStarAngles.append(Double.random(in: 0...360))
            initialStarColors.append(starColorOptions.randomElement() ?? .yellow)
        }
        
        _starScales = State(initialValue: initialStarScales)
        _starPositions = State(initialValue: initialStarPositions)
        _starAngles = State(initialValue: initialStarAngles)
        _starColors = State(initialValue: initialStarColors)
    }
    
    var body: some View {
        ZStack {
            if isVisible {
                Color.black.opacity(0.7)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                
                VStack(spacing: 30) {
                    Text("GOOD JOB!")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.yellow)
                        .multilineTextAlignment(.center)
                        .shadow(color: .orange, radius: 2)
                        .opacity(showText ? 1 : 0)
                        .scaleEffect(showText ? 1 : 0.5)
                        .animation(settings.animation(.spring(response: 0.6, dampingFraction: 0.7)), value: showText)

                        
                    Image(systemName: "trophy.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.yellow)
                        .shadow(color: .orange, radius: 10)
                        .opacity(showText ? 1 : 0)
                        .scaleEffect(showText ? 1 : 0.1)
                        .animation(settings.animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.5)), value: showText)
                }
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.black.opacity(0.8))
                        .shadow(color: .yellow.opacity(0.6), radius: 20)
                )
                .opacity(showStars ? 1 : 0)
                .animation(settings.animation(.easeIn.delay(1.5)), value: showStars)

                if !settings.motionReduced {
                    ForEach(0..<starCount, id: \.self) { index in
                    Star()
                        .fill(starColors[index])
                        .frame(width: 30, height: 30)
                        .scaleEffect(starScales[index])
                        .rotationEffect(.degrees(starAngles[index]))
                        .position(x: starPositions[index].x,
                                  y: showStars ? UIScreen.main.bounds.height + 100 : starPositions[index].y)
                        .opacity(showStars ? 0.9 : 0)
                        .animation(
                            Animation.easeIn(duration: 3.0)
                                .delay(Double(index) * 0.03)
                                .repeatCount(1, autoreverses: false),
                            value: showStars
                        )
                    }
                }
            }
        }
        .onChange(of: isVisible) { visible in
            if visible {
                startAnimations()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                    onComplete()
                }
            } else {
                resetAnimations()
            }
        }
    }
    
    private func startAnimations() {
        guard !settings.motionReduced else {
            // Reward still appears, just without the shower or the staged reveal.
            showStars = true
            showText = true
            return
        }

        withAnimation {
            showStars = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                showText = true
            }
        }
    }
    
    private func resetAnimations() {
        showStars = false
        showText = false
    }
}

struct Star: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let pointCount = 5
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        
        var path = Path()
        
        for i in 0..<pointCount * 2 {
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let angle = Double(i) * .pi / Double(pointCount)
            let x = center.x + CGFloat(cos(angle)) * radius
            let y = center.y + CGFloat(sin(angle)) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.closeSubpath()
        return path
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
