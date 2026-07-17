//
//  SwiftUIView.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 20/02/25.
//

import SwiftUI

struct CompactMenuButton: View {
    let title: String
    let icon: String
    let color: Color
    @Binding var scale: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 0.95
            }
            
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                AudioPlayerManager.shared.playAudio(named: "tapButton", withExtension: "mp3")
            }
            
            AudioPlayerManager.shared.stopBackgroundMusic()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                AudioPlayerManager.shared.playBackgroundMusic(
                    named: AudioConstants.gameMusic,
                    withExtension: AudioConstants.audioExtension
                )
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                scale = 1.0
                action()
            }
        } label: {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(color)
                            .shadow(color: color.opacity(0.4), radius: 5, x: 0, y: 3)
                    )
                
                Text(title)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.8))
                
                Spacer()
                
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 22))
                    .foregroundColor(color.opacity(0.7))
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(color, lineWidth: 2.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(scale)
        .animation(.spring(response: 0.3), value: scale)
    }
}
