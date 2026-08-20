import SwiftUI

struct MenuView: View {
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var settings: SensorySettings

    @State private var animateBackground = false
    @State private var showButtons = false

    private static let menuItems = [
        (title: "Jigsaw Puzzle", icon: "puzzlepiece.fill", color: Color.cyan, destination: Destination.jigsawPuzzle),
        (title: "Matching", icon: "equal.circle.fill", color: Color.brown, destination: Destination.matchingPuzzle),
        (title: "Sorting", icon: "arrow.up.and.down.circle.fill", color: Color.green, destination: Destination.sortingPuzzle),
        (title: "Tracing", icon: "hand.draw.fill", color: Color.orange, destination: Destination.tracingPuzzle),
        (title: "Feelings", icon: "face.smiling.fill", color: Color.purple, destination: Destination.emotionMatching),
        (title: "My Routine", icon: "list.number", color: Color.teal, destination: Destination.routineSequencing),
        (title: "Tap & Play", icon: "hand.tap.fill", color: Color.yellow, destination: Destination.causeEffect)
    ]

    // Sized from menuItems.count rather than a fixed literal - a fixed-size
    // array here was exactly what caused the "Index out of range" crash when
    // 3 more games were added to menuItems without updating this alongside it.
    @State private var buttonScale: [CGFloat]

    init() {
        _buttonScale = State(initialValue: Array(repeating: 1.0, count: Self.menuItems.count))
    }
    
    var body: some View {
        GeometryReader { outerGeometry in
        let isPortrait = outerGeometry.size.height > outerGeometry.size.width
        ZStack {
            GeometryReader { bgGeometry in
                Image("backgroundMenu")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: bgGeometry.size.width, height: bgGeometry.size.height)
                    .clipped()
            }
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

            // Top bar - an independent ZStack sibling pinned to the top via its own
            // internal Spacer, rather than sharing a parent VStack with the main
            // content below. Sharing one meant this row's Spacer and the content's
            // Spacers were competing for the same leftover space in a way that
            // wasn't predictable, and empirically came out uneven (a large gap
            // above "Choose Puzzle" but almost none below the button grid).
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

                Spacer()
            }
            .animation(
                .spring(response: 0.5, dampingFraction: 0.7)
                .delay(0.3),
                value: showButtons
            )

            // Main content - a single VStack with one Spacer on each side of the
            // title+grid block guarantees they split the remaining space equally
            // (true centering), instead of the previous two-separate-VStacks
            // arrangement where that wasn't guaranteed. Padded from the top by
            // roughly the top bar's own height so this centers within the space
            // below it rather than the full screen (which risked overlapping the
            // top bar on landscape's short height).
            VStack(spacing: 20) {
                Spacer()

                HStack(spacing: 10) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 30))

                    Text("Choose Puzzle")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)

                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 30))
                }
                .offset(y: showButtons ? 0 : -60)
                .opacity(showButtons ? 1 : 0)

                // An adaptive grid rather than a hardcoded isPortrait 4x1 list /
                // landscape 2x2 grid - the old landscape branch indexed exactly
                // 4 buttons by position, so adding a 5th game would have silently
                // made it unreachable in landscape. .adaptive(minimum:) naturally
                // gives 1 column on a narrow iPhone portrait and 2+ once there's
                // room, for any number of games. Wrapped in a ScrollView so a
                // growing game list never overflows a short screen instead of
                // relying on exact-fit math.
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 320), spacing: 22)], spacing: 22) {
                        ForEach(0..<Self.menuItems.count, id: \.self) { index in
                            menuButton(at: index)
                        }
                    }
                }
                .frame(maxHeight: isPortrait ? .infinity : 260)

                Spacer()
            }
            .padding(.horizontal, 25)
            .padding(.top, 85)
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
    
    @ViewBuilder
    private func menuButton(at index: Int) -> some View {
        CompactMenuButton(
            title: Self.menuItems[index].title,
            icon: Self.menuItems[index].icon,
            color: Self.menuItems[index].color,
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

    private func handleButtonPress(at index: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            buttonScale[index] = 0.95
        }
        
        Haptic.shared.success()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            buttonScale[index] = 1.0
            router.navigate(to: Self.menuItems[index].destination)
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
