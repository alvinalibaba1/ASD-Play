import SwiftUI

struct MenuView: View {
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var settings: SensorySettings

    @State private var animateBackground = false
    @State private var buttonScale: [CGFloat] = [1.0, 1.0, 1.0, 1.0]
    @State private var showButtons = false
    
    private let menuItems = [
        (title: "Jigsaw Puzzle", icon: "puzzlepiece.fill", color: Color.cyan, destination: Destination.jigsawPuzzle),
        (title: "Matching", icon: "equal.circle.fill", color: Color.brown, destination: Destination.matchingPuzzle),
        (title: "Sorting", icon: "arrow.up.and.down.circle.fill", color: Color.green, destination: Destination.sortingPuzzle),
        (title: "Tracing", icon: "hand.draw.fill", color: Color.orange, destination: Destination.tracingPuzzle)
    ]
    
    var body: some View {
        ZStack {
            Image("backgroundMenu")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .saturation(animateBackground ? 1.05 : 1.0)
                .brightness(animateBackground ? 0.03 : 0)
                .animation(
                    settings.motionReduced
                        ? nil
                        : Animation.easeInOut(duration: 4.0).repeatForever(autoreverses: true),
                    value: animateBackground
                )
                .onAppear {
                    if !settings.motionReduced { animateBackground = true }
                }
            
            Color.white.opacity(0.2)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                VStack {
                    HStack {
                        CustomBackButton()
                            .scaleEffect(0.8)
                            .opacity(showButtons ? 1 : 0)
                            .offset(x: showButtons ? 0 : -60)
                        Spacer()
                        HStack(spacing: 14) {
                            ProgressButton()
                            SettingsButton()
                        }
                        .scaleEffect(0.8)
                        .opacity(showButtons ? 1 : 0)
                        .offset(x: showButtons ? 0 : 60)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 0)
                    
                    Spacer()
                }
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.7)
                    .delay(0.3),
                    value: showButtons
                )
                
                VStack(spacing: 20) {
                    HStack(spacing: 10) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 30))
                        
                        Text("Choose Puzzle")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                        
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 30))
                    }
                    .offset(y: showButtons ? 0 : -60)
                    .opacity(showButtons ? 1 : 0)
                    
                    Spacer()
                    
                    VStack(spacing: 22) {
                        ForEach(0..<menuItems.count, id: \.self) { index in
                            CompactMenuButton(
                                title: menuItems[index].title,
                                icon: menuItems[index].icon,
                                color: menuItems[index].color,
                                scale: $buttonScale[index],
                                action: {
                                    handleButtonPress(at: index)
                                }
                            )
                            .scaleEffect(showButtons ? 1 : 0.5)
                            .opacity(showButtons ? 1 : 0)
                            .offset(y: showButtons ? 0 : 60)
                            .animation(
                                Animation.spring(response: 0.5, dampingFraction: 0.7)
                                    .delay(Double(index) * 0.1),
                                value: showButtons
                            )
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            startEntryAnimation()
            if !AudioPlayerManager.shared.isIntroMusicPlaying {
                AudioPlayerManager.shared.playBackgroundMusic(
                    named: AudioConstants.introMusic,
                    withExtension: AudioConstants.audioExtension
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .allowsHitTesting(showButtons)
    }
    
    private func handleButtonPress(at index: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            buttonScale[index] = 0.95
        }
        
        Haptic.shared.success()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            buttonScale[index] = 1.0
            router.navigate(to: menuItems[index].destination)
        }
    }
    
    private func startEntryAnimation() {
        guard !settings.motionReduced else {
            // No entrance choreography, but the buttons must still become interactive.
            showButtons = true
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                showButtons = true
            }
        }
    }
}
