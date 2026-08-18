import SwiftUI

struct EmotionMatchingView: View {
    @EnvironmentObject var router: NavigationRouter
    @StateObject private var viewModel: EmotionMatchingViewModel

    init(viewModel: EmotionMatchingViewModel) {
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

                Color.purple.opacity(0.15)
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

                    Spacer()

                    Text("How does this face feel?")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.black.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)

                    Text(viewModel.currentRound.target.emoji)
                        .font(.system(size: min(geometry.size.width, geometry.size.height) * 0.35))
                        .id(viewModel.currentRound.target)
                        .transition(.scale.combined(with: .opacity))
                        .padding(.vertical, 20)

                    HStack(spacing: 24) {
                        ForEach(viewModel.currentRound.options, id: \.self) { option in
                            optionButton(for: option)
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
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.currentRound.target)
        }
        .onAppear {
            AudioPlayerManager.shared.playBackgroundMusic(named: AudioConstants.gameMusic, withExtension: AudioConstants.audioExtension)
        }
        .onDisappear {
            AudioPlayerManager.shared.stopBackgroundMusic()
            AudioPlayerManager.shared.playBackgroundMusic(named: AudioConstants.introMusic, withExtension: AudioConstants.audioExtension)
        }
        .blockInteractions(when: viewModel.showSuccessOverlay)
        .onChange(of: viewModel.shouldReturnToMenu) { shouldReturn in
            if shouldReturn {
                router.navigateToRoot()
                router.navigate(to: .menu)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var progressBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "face.smiling.fill")
                .font(.system(size: 14, weight: .semibold))
            Text("\(viewModel.roundsCompleted)/\(viewModel.totalRounds)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color.purple.opacity(0.85)))
        .shadow(radius: 4)
    }

    private func optionButton(for emotion: Emotion) -> some View {
        let isSelected = viewModel.lastSelection == emotion
        let isWrongSelection = isSelected && emotion != viewModel.currentRound.target

        return Button {
            viewModel.selectAnswer(emotion)
        } label: {
            VStack(spacing: 8) {
                Text(emotion.emoji)
                    .font(.system(size: 60))
                Text(emotion.label)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.black.opacity(0.7))
            }
            .frame(width: 100, height: 110)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.9))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isWrongSelection ? Color.red.opacity(0.6) : Color.purple.opacity(0.3), lineWidth: 3)
            )
            .shadow(radius: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(viewModel.lastSelection != nil)
        .offset(x: isWrongSelection ? -6 : 0)
        .animation(isWrongSelection ? .default.repeatCount(3).speed(6) : .default, value: isWrongSelection)
    }
}
