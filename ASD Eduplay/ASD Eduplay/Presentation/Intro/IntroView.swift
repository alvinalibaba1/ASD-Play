import SwiftUI
import AVFoundation


struct IntroView: View {
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var settings: SensorySettings
    @State private var leftBirdOffset = CGSize.zero
    @State private var rightBirdOffset = CGSize.zero
    @State private var leftCloudOffset = CGSize.zero
    @State private var rightCloudOffset = CGSize.zero
    @State private var showButtons = false
    @State private var buttonScales: [CGFloat] = [1.0, 1.0]
    @State private var audioPlayer: AVAudioPlayer?
    @State private var flapWings = false
    
    private let audioService = AudioPlayerManager.shared
    
    var body: some View {
        ZStack {
            Image("backgroundIntro")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            Image("birdIntro")
                .resizable()
                .scaledToFit()
                .frame(width: 120)
                .rotationEffect(flapWings ? Angle(degrees: 10) : Angle(degrees: -10))
                .offset(x: -UIScreen.main.bounds.width/3 + leftBirdOffset.width,
                        y: -UIScreen.main.bounds.height/3)
            
            Image("birdIntro")
                .resizable()
                .scaledToFit()
                .frame(width: 120)
                .scaleEffect(x: -1, y: 1)
                .rotationEffect(flapWings ? Angle(degrees: -8) : Angle(degrees: 8))
                .offset(x: UIScreen.main.bounds.width/3 + rightBirdOffset.width,
                        y: -UIScreen.main.bounds.height/4)
            
            Image("cloud")
                .resizable()
                .scaledToFit()
                .frame(width: 220)
                .opacity(0.85)
                .offset(x: -UIScreen.main.bounds.width/2.5 + leftCloudOffset.width,
                        y: -UIScreen.main.bounds.height/2.5)
            
            Image("cloud")
                .resizable()
                .scaledToFit()
                .frame(width: 180)
                .opacity(0.75)
                .offset(x: UIScreen.main.bounds.width/2.5 + rightCloudOffset.width,
                        y: -UIScreen.main.bounds.height/3)
            
            
            VStack {
                VStack(spacing: 0) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 500)
                    
                    HeartbeatPlayButton {
                        Haptic.shared.tap()
                        AudioPlayerManager.shared.playAudio(named: "tapButton", withExtension: "mp3")
                        router.navigate(to: .menu)
                    }
                    .padding(.bottom, 80)

                    CreditButton(
                        title: "Credit"
                    ) {
                        Haptic.shared.tap()
                        AudioPlayerManager.shared.playAudio(named: "tapButton", withExtension: "mp3")
                        router.navigate(to: .credit)
                    }
                    .frame(width: 300, height: 80)
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 50)
            }

            VStack {
                HStack {
                    Spacer()
                    SettingsButton()
                        .padding(.trailing, 20)
                }
                .padding(.top, 20)

                Spacer()
            }

            Spacer()
        }
        // Rebuilds the subtree when the motion preference flips, which resets the
        // repeatForever animations that SwiftUI otherwise keeps running.
        .id(settings.motionReduced)
        .onAppear {
            startAnimations()
            if !AudioPlayerManager.shared.isIntroMusicPlaying {
                AudioPlayerManager.shared.playBackgroundMusic(
                    named: AudioConstants.introMusic,
                    withExtension: AudioConstants.audioExtension
                )
            }
            
        }
    }
    
    
    private func handleButtonPress(index: Int, action: @escaping () -> Void) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            buttonScales[index] = 0.95
        }
        
        Haptic.shared.success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            buttonScales[index] = 1.0
            action()
        }
    }

    
    
    private func startAnimations() {
        guard !settings.motionReduced else { return }

        withAnimation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            flapWings = true
        }
        
        withAnimation(Animation.linear(duration: 16).repeatForever(autoreverses: false)) {
            leftBirdOffset = CGSize(width: UIScreen.main.bounds.width * 1.5, height: 0)
            rightBirdOffset = CGSize(width: -UIScreen.main.bounds.width * 1.5, height: 0)
        }
        
        withAnimation(Animation.linear(duration: 45).repeatForever(autoreverses: false)) {
            leftCloudOffset = CGSize(width: UIScreen.main.bounds.width * 1.2, height: 0)
            rightCloudOffset = CGSize(width: -UIScreen.main.bounds.width * 1.2, height: 0)
        }
    }
    
}
