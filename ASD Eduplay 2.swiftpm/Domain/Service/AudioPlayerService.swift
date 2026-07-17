//
//  File.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 14/02/25.
//

import Foundation
import AVFoundation

@MainActor
protocol AudioPlayerService {
    func playAudio(named filename: String, withExtension fileExtension: String)
    func playBackgroundMusic(named filename: String, withExtension fileExtension: String)
    func playCorrectActionSound()
    func playIncorrectActionSound()
    func playPuzzleCompleteSound()
    func playRoundCompleteSound()
    func stopAudio()
    func pauseAudio()
    func resumeAudio()
    func isPlaying() -> Bool
}

class AudioPlayerManager: NSObject, @preconcurrency AVAudioPlayerDelegate, AudioPlayerService {
    static let shared = AudioPlayerManager()
    private var audioPlayer: AVAudioPlayer?
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var isTransitioning = false
    
    private(set) var isIntroMusicPlaying: Bool = false
    
    private override init() {
        super.init()
        setupAudioSession()
    }
    
    func playAudio(named filename: String, withExtension fileExtension: String) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: fileExtension) else {
            print("Could not find audio file: \(filename).\(fileExtension)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
    
    private func setupAudioSession() {
            do {
                try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Failed to set up audio session: \(error)")
            }
        }
        
        func playBackgroundMusic(named filename: String, withExtension fileExtension: String) {
            guard !isTransitioning else { return }
            isTransitioning = true
            
            if filename == AudioConstants.introMusic {
                     isIntroMusicPlaying = true
                 }
            
            if let currentPlayer = backgroundMusicPlayer, currentPlayer.isPlaying {
                fadeOutBackgroundMusic {
                    self.startNewBackgroundMusic(filename: filename, fileExtension: fileExtension)
                }
            } else {
                startNewBackgroundMusic(filename: filename, fileExtension: fileExtension)
            }
        }
        
        private func startNewBackgroundMusic(filename: String, fileExtension: String) {
            guard let url = Bundle.main.url(forResource: filename, withExtension: fileExtension) else {
                print("Could not find background music: \(filename).\(fileExtension)")
                isTransitioning = false
                return
            }
            
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
                backgroundMusicPlayer?.delegate = self
                backgroundMusicPlayer?.numberOfLoops = -1
                backgroundMusicPlayer?.volume = 0.0 
                backgroundMusicPlayer?.prepareToPlay()
                backgroundMusicPlayer?.play()
                
                fadeInBackgroundMusic()
            } catch {
                print("Error playing background music: \(error)")
                isTransitioning = false
            }
        }
        
        private func fadeOutBackgroundMusic(completion: @escaping () -> Void) {
            guard let player = backgroundMusicPlayer else {
                completion()
                return
            }
            
            let fadeOutDuration: TimeInterval = 0.5
            let steps = 10
            let volumeStep = player.volume / Float(steps)
            let stepDuration = fadeOutDuration / TimeInterval(steps)
            
            func fadeStep(step: Int) {
                DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(step)) {
                    player.volume = player.volume - volumeStep
                    
                    if step == steps - 1 {
                        player.stop()
                        completion()
                    }
                }
            }
            
            for step in 0..<steps {
                fadeStep(step: step)
            }
        }
        
        private func fadeInBackgroundMusic() {
            guard let player = backgroundMusicPlayer else {
                isTransitioning = false
                return
            }
            
            let fadeInDuration: TimeInterval = 0.5
            let steps = 10
            let targetVolume: Float = 0.6
            let volumeStep = targetVolume / Float(steps)
            let stepDuration = fadeInDuration / TimeInterval(steps)
            
            func fadeStep(step: Int) {
                DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(step)) {
                    player.volume = volumeStep * Float(step + 1)
                    
                    if step == steps - 1 {
                        self.isTransitioning = false
                    }
                }
            }
            
            for step in 0..<steps {
                fadeStep(step: step)
            }
        }
        
        func stopBackgroundMusic() {
            fadeOutBackgroundMusic { }
        }
    
    func playCorrectActionSound() {
        playAudio(named: AudioConstants.correctAction, withExtension: AudioConstants.audioExtension)
    }
    
    func playIncorrectActionSound() {
        playAudio(named: AudioConstants.incorrectAction, withExtension: AudioConstants.audioExtension)
    }
    
    func playPuzzleCompleteSound() {
        playAudio(named: AudioConstants.puzzleComplete, withExtension: AudioConstants.audioExtension)
    }
    
    func playRoundCompleteSound() {
        playAudio(named: AudioConstants.roundComplete, withExtension: AudioConstants.audioExtension)
    }

    
    
    func stopAudio() {
        audioPlayer?.stop()
    }
    
    func pauseAudio() {
        audioPlayer?.pause()
    }
    
    func resumeAudio() {
        audioPlayer?.play()
    }
    
    func isPlaying() -> Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Audio finished playing successfully: \(flag)")
    }
}
