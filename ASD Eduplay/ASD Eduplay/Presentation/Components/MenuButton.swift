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
            
            Haptic.shared.tap()

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
            // Icon circle, title, and tap-hint were fixed pixel sizes that made
            // sense when the card was narrower - now that the button spans
            // almost the full screen width (see MenuView's adaptive grid), those
            // small fixed accents read as lost at the edges with a lot of empty
            // middle. Scaled everything up together so the accents fill the
            // card's actual size instead of floating in it - which also grows
            // the touch targets, a plus for this audience.
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundColor(.white)
                    .frame(width: 76, height: 76)
                    .background(
                        Circle()
                            .fill(color)
                            .shadow(color: color.opacity(0.4), radius: 6, x: 0, y: 3)
                    )

                Text(title)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.8))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                Spacer()

                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 28))
                    .foregroundColor(color.opacity(0.7))
            }
            .padding(.vertical, 22)
            .padding(.horizontal, 24)
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
