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

                    // "Tap what happens next" previously sat between two
                    // Spacer()s, so as scrambledSteps shrank (each correct
                    // tap removes a card) the grid below it got shorter and
                    // both spacers redistributed the freed space - the label
                    // visibly drifted down every time a card disappeared. A
                    // single fixed gap here instead means its position only
                    // depends on the fixed content above it; the one trailing
                    // Spacer() below absorbs all the leftover space instead,
                    // where it can't push anything above it around.
                    Text("Tap what happens next")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.black.opacity(0.6))
                        .padding(.top, 30)

                    // GridItem(.adaptive(minimum: 160)) with 30pt padding on
                    // each side needs 336pt for 2 columns (160*2 + 16
                    // spacing) - narrower phones (iPhone SE/mini, ~375pt
                    // wide, ~315pt available) don't have that much room, so
                    // it silently collapsed to a single column. Each card
                    // then took the full row width instead of half of it,
                    // producing oversized stacked cards that needed scrolling
                    // to see. Computing the card size directly from the
                    // actual available width instead guarantees exactly 2
                    // columns on every device.
                    let gridSpacing: CGFloat = 16
                    let gridHorizontalPadding: CGFloat = 20
                    let cardSize = min(150, (geometry.size.width - gridHorizontalPadding * 2 - gridSpacing) / 2)

                    LazyVGrid(columns: [GridItem(.fixed(cardSize), spacing: gridSpacing), GridItem(.fixed(cardSize))], spacing: gridSpacing) {
                        ForEach(viewModel.scrambledSteps) { step in
                            stepButton(for: step, size: cardSize)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, gridHorizontalPadding)

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
            Image(systemName: "list.number")
                .font(.system(size: 14, weight: .semibold))
            Text("\(viewModel.completedSets)/\(viewModel.totalSets)")
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
        // Without this, a VoiceOver user reviewing the sequence built so far
        // gets nothing for an empty slot (the custom image has no default
        // description) and just a bare number for a filled one.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(placedStep.map { "Step \(order): \($0.title)" } ?? "Step \(order): empty")
    }

    private func stepButton(for step: RoutineStep, size: CGFloat) -> some View {
        let isWrong = viewModel.lastWrongStepId == step.id
        let imageSize = size * 0.45
        let imageCircleSize = size * 0.56

        return Button {
            viewModel.selectStep(step)
        } label: {
            VStack(spacing: 8) {
                Image(step.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageSize, height: imageSize)
                    .frame(width: imageCircleSize, height: imageCircleSize)
                    .background(Circle().fill(Color.teal.opacity(0.15)))
                Text(step.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.black.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: size, height: size)
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(step.title)
        .accessibilityAddTraits(.isButton)
    }
}
