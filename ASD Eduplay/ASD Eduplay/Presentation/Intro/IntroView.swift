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
        GeometryReader { geometry in
        let isPortrait = geometry.size.height > geometry.size.width
        ZStack {
            GeometryReader { bgGeometry in
                Image("backgroundIntro")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: bgGeometry.size.width, height: bgGeometry.size.height)
                    .clipped()
            }
            .edgesIgnoringSafeArea(.all)

            Image("birdIntro")
                .resizable()
                .scaledToFit()
                .frame(width: 120)
                .rotationEffect(flapWings ? Angle(degrees: 10) : Angle(degrees: -10))
                .offset(x: -geometry.size.width/3 + leftBirdOffset.width,
                        y: -geometry.size.height/3)

            Image("birdIntro")
                .resizable()
                .scaledToFit()
                .frame(width: 120)
                .scaleEffect(x: -1, y: 1)
                .rotationEffect(flapWings ? Angle(degrees: -8) : Angle(degrees: 8))
                .offset(x: geometry.size.width/3 + rightBirdOffset.width,
                        y: -geometry.size.height/4)

            Image("cloud")
                .resizable()
                .scaledToFit()
                .frame(width: 220)
                .opacity(0.85)
                .offset(x: -geometry.size.width/2.5 + leftCloudOffset.width,
                        y: -geometry.size.height/2.5)

            Image("cloud")
                .resizable()
                .scaledToFit()
                .frame(width: 180)
                .opacity(0.75)
                .offset(x: geometry.size.width/2.5 + rightCloudOffset.width,
                        y: -geometry.size.height/3)


            if isPortrait {
                VStack {
                    VStack(spacing: 0) {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: min(500, geometry.size.width * 0.85))

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
            } else {
                // Stacking the logo above both buttons needed ~690pt of height
                // (logo + play button + its padding + credit button + outer
                // padding), far more than an iPhone's landscape height. Placing the
                // logo beside the buttons instead uses landscape's abundant width
                // rather than fighting its short height.
                HStack(spacing: 40) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: min(260, geometry.size.height * 0.75))

                    VStack(spacing: 16) {
                        HeartbeatPlayButton {
                            Haptic.shared.tap()
                            AudioPlayerManager.shared.playAudio(named: "tapButton", withExtension: "mp3")
                            router.navigate(to: .menu)
                        }

                        CreditButton(
                            title: "Credit"
                        ) {
                            Haptic.shared.tap()
                            AudioPlayerManager.shared.playAudio(named: "tapButton", withExtension: "mp3")
                            router.navigate(to: .credit)
                        }
                        .frame(width: 220, height: 60)
                    }
                }
                .padding(.horizontal, 40)
            }

            VStack {
                HStack(spacing: 14) {
                    Spacer()
                    ProgressButton()
                    SettingsButton()
                        .padding(.trailing, 20)
                }
                .padding(.top, 20)

                Spacer()
            }

            Spacer()
        }
        // Rebuilds the subtree when the motion preference or the screen width changes
        // (e.g. rotation), which resets the repeatForever animations that SwiftUI
        // otherwise keeps running toward a stale, now-incorrect target distance.
        .id("\(settings.motionReduced)_\(Int(geometry.size.width))")
        .onAppear {
            startAnimations(screenWidth: geometry.size.width)
            if !AudioPlayerManager.shared.isIntroMusicPlaying {
                AudioPlayerManager.shared.playBackgroundMusic(
                    named: AudioConstants.introMusic,
                    withExtension: AudioConstants.audioExtension
                )
            }

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

    
    
    private func startAnimations(screenWidth: CGFloat) {
        guard !settings.motionReduced else { return }

        withAnimation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            flapWings = true
        }

        withAnimation(Animation.linear(duration: 16).repeatForever(autoreverses: false)) {
            leftBirdOffset = CGSize(width: screenWidth * 1.5, height: 0)
            rightBirdOffset = CGSize(width: -screenWidth * 1.5, height: 0)
        }

        withAnimation(Animation.linear(duration: 45).repeatForever(autoreverses: false)) {
            leftCloudOffset = CGSize(width: screenWidth * 1.2, height: 0)
            rightCloudOffset = CGSize(width: -screenWidth * 1.2, height: 0)
        }
    }
    
}
