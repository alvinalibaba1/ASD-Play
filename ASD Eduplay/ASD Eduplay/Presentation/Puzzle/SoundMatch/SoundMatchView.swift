import SwiftUI

struct SoundMatchView: View {
    @EnvironmentObject var router: NavigationRouter
    @StateObject private var viewModel: SoundMatchViewModel

    init(viewModel: SoundMatchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        GeometryReader { geometry in
            let isPortrait = geometry.size.height > geometry.size.width

            ZStack {
                GeometryReader { bgGeometry in
                    Image("backgroundMenu")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: bgGeometry.size.width, height: bgGeometry.size.height)
                        .clipped()
                }
                .edgesIgnoringSafeArea(.all)

                Color.indigo.opacity(0.12)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    HStack {
                        CustomBackButton()
                            .padding(.leading, 20)
                        Spacer()
                        progressBadge
                            .padding(.trailing, 20)
                    }
                    .padding(.top, isPortrait ? 20 : 40)

                    Text("What do you hear?")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.black.opacity(0.75))
                        .padding(.top, 10)

                    Spacer()

                    replayButton
                        .id(viewModel.currentRound.target.id)

                    Spacer()

                    HStack(spacing: 24) {
                        ForEach(viewModel.currentRound.options) { item in
                            optionButton(for: item)
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }

                SuccessOverlay(
                    isVisible: viewModel.showSuccessOverlay,
                    onComplete: {
                        viewModel.finishSuccessAndReturnToMenu()
                    }
                )
            }
        }
        .onAppear {
            AudioPlayerManager.shared.playBackgroundMusic(named: AudioConstants.gameMusic, withExtension: AudioConstants.audioExtension)
        }
        .onDisappear {
            AudioPlayerManager.shared.stopBackgroundMusic()
            AudioPlayerManager.shared.playBackgroundMusic(named: AudioConstants.introMusic, withExtension: AudioConstants.audioExtension)
        }
        .blockInteractions(when: viewModel.showSuccessOverlay)
        .onChange(of: viewModel.shouldReturnToMenu) { _, shouldReturn in
            if shouldReturn {
                router.navigateToRoot()
                router.navigate(to: .menu)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var progressBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "speaker.wave.2.fill")
                .font(.system(size: 14, weight: .semibold))
            Text("\(viewModel.roundsCompleted)/\(viewModel.totalRounds)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color.indigo.opacity(0.85)))
        .shadow(radius: 4)
    }

    private var replayButton: some View {
        Button {
            viewModel.playTargetSound()
        } label: {
            ZStack {
                Circle()
                    .fill(Color.indigo)
                    .shadow(color: Color.indigo.opacity(0.4), radius: 10, x: 0, y: 4)

                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 120, height: 120)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Play sound")
        .accessibilityHint("Tap to hear the sound again")
    }

    private func optionButton(for item: SoundMatchItem) -> some View {
        let isSelected = viewModel.lastSelection?.id == item.id
        let isWrongSelection = isSelected && item.id != viewModel.currentRound.target.id

        return Button {
            viewModel.selectAnswer(item)
        } label: {
            VStack(spacing: 8) {
                Image(item.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                Text(item.label)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.black.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 100, height: 120)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.9))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(isWrongSelection ? Color.red.opacity(0.6) : Color.indigo.opacity(0.3), lineWidth: 3)
            )
            .shadow(radius: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(viewModel.lastSelection != nil)
        .offset(x: isWrongSelection ? -6 : 0)
        .animation(isWrongSelection ? .default.repeatCount(3).speed(6) : .default, value: isWrongSelection)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.label)
        .accessibilityAddTraits(.isButton)
    }
}
