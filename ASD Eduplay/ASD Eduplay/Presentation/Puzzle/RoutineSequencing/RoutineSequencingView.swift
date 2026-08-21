import SwiftUI

struct RoutineSequencingView: View {
    @EnvironmentObject var router: NavigationRouter
    @StateObject private var viewModel: RoutineSequencingViewModel

    init(viewModel: RoutineSequencingViewModel) {
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

                Color.teal.opacity(0.15)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    HStack {
                        CustomBackButton()
                            .padding(.leading, 20)
                        Spacer()
                        progressBadge
                            .padding(.trailing, 20)
                    }
                    .padding(.top, isPortrait ? 20 : 40)

                    Text(viewModel.currentSet.name)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.black.opacity(0.75))

                    // The sequence being built so far - a fixed row of numbered
                    // slots that fills in left to right as steps are tapped in
                    // the right order.
                    HStack(spacing: 10) {
                        ForEach(1...viewModel.currentSet.steps.count, id: \.self) { order in
                            sequenceSlot(order: order)
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    Text("Tap what happens next")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.black.opacity(0.6))

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
                        ForEach(viewModel.scrambledSteps) { step in
                            stepButton(for: step)
                        }
                    }
                    .padding(.horizontal, 30)

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
            Image(systemName: "list.number")
                .font(.system(size: 14, weight: .semibold))
            Text("\(viewModel.currentSetIndex + 1)/\(viewModel.totalSets)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color.teal.opacity(0.85)))
        .shadow(radius: 4)
    }

    private func sequenceSlot(order: Int) -> some View {
        let placedStep = order <= viewModel.placedSteps.count ? viewModel.placedSteps[order - 1] : nil

        return ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(placedStep == nil ? Color.white.opacity(0.5) : Color.white.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.teal.opacity(0.4), style: StrokeStyle(lineWidth: 2, dash: placedStep == nil ? [6, 4] : []))
                )

            if let placedStep {
                VStack(spacing: 2) {
                    Image(placedStep.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 38, height: 38)
                    Text("\(order)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.black.opacity(0.5))
                }
            } else {
                Text("\(order)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.black.opacity(0.3))
            }
        }
        .frame(width: 76, height: 76)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: placedStep?.id)
    }

    private func stepButton(for step: RoutineStep) -> some View {
        let isWrong = viewModel.lastWrongStepId == step.id

        return Button {
            viewModel.selectStep(step)
        } label: {
            VStack(spacing: 8) {
                Image(step.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 68, height: 68)
                    .frame(width: 84, height: 84)
                    .background(Circle().fill(Color.teal.opacity(0.15)))
                Text(step.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.black.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 150, height: 150)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.9))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(isWrong ? Color.red.opacity(0.6) : Color.teal.opacity(0.25), lineWidth: 3)
            )
            .shadow(radius: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .offset(x: isWrong ? -6 : 0)
        .animation(isWrong ? .default.repeatCount(3).speed(6) : .default, value: isWrong)
    }
}
