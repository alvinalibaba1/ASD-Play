//
//  SwiftUIView.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 19/02/25.
//

import SwiftUI

struct HeartbeatPlayButton: View {
    @EnvironmentObject var settings: SensorySettings
    @State private var isAnimating = false
    @State private var scale: CGFloat = 1.0
    let action: () -> Void
    
    let gradientColors = [
        Color(.blue),
        Color(.cyan)
     
    ]
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                scale = 1.3
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                action()
            }
        }) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [gradientColors[0].opacity(0.3), Color.clear]),
                            center: .center,
                            startRadius: 50,
                            endRadius: 120
                        )
                    )
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .opacity(isAnimating ? 0.6 : 0.3)
                
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 4)
                            .blur(radius: 4)
                            .offset(x: 2, y: 2)
                            .mask(Circle().fill(LinearGradient(gradient: Gradient(colors: [Color.black, Color.clear]), startPoint: .top, endPoint: .bottom)))
                    )
                    .shadow(color: gradientColors[1].opacity(0.5), radius: 15, x: 0, y: 8)
                
                Image(systemName: "play.fill")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.white)
                    .offset(x: 3)
                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
            }
            .frame(width: 100, height: 100)
            .scaleEffect(scale)
            .animation(Animation.easeInOut(duration: 0.2), value: scale)
            .onChange(of: scale) { newScale in
                if newScale > 1.0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        scale = 1.0
                    }
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .onAppear {
            startHeartbeatAnimation()
        }
    }
    
    private func startHeartbeatAnimation() {
        guard !settings.motionReduced else { return }

        let animation = Animation
            .easeInOut(duration: 0.5)
            .delay(0.1)
            .repeatForever(autoreverses: true)
        
        withAnimation(animation) {
            isAnimating.toggle()
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .brightness(configuration.isPressed ? 0.1 : 0)
    }
}
