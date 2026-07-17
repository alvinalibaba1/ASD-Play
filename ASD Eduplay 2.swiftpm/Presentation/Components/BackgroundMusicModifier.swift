//
//  SwiftUIView.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 21/02/25.
//

import SwiftUI

struct BackgroundMusicModifier: ViewModifier {
    let musicTrack: String
    let shouldRestart: Bool
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if shouldRestart {
                    AudioPlayerManager.shared.playBackgroundMusic(
                        named: musicTrack,
                        withExtension: "mp3"
                    )
                }
            }
            .onDisappear {
                if shouldRestart {
                    AudioPlayerManager.shared.stopBackgroundMusic()
                }
            }
    }
}

extension View {
    func backgroundMusic(_ track: String, shouldRestart: Bool = false) -> some View {
        modifier(BackgroundMusicModifier(musicTrack: track, shouldRestart: shouldRestart))
    }
}
