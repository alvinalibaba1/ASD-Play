import SwiftUI

struct CauseEffectView: View {
    @StateObject private var viewModel: CauseEffectViewModel

    init(viewModel: CauseEffectViewModel) {
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

                Color.yellow.opacity(0.12)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    HStack {
                        CustomBackButton()
                            .padding(.leading, 20)
                        Spacer()
                    }
                    .padding(.top, isPortrait ? 20 : 40)

                    Text("Tap and see what happens!")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.black.opacity(0.75))

                    Spacer()

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 20)], spacing: 20) {
                        ForEach(viewModel.items) { item in
                            itemButton(for: item)
                        }
                    }
                    .padding(.horizontal, 30)

                    Spacer()
                }
            }
        }
        .onAppear {
            AudioPlayerManager.shared.playBackgroundMusic(named: AudioConstants.gameMusic, withExtension: AudioConstants.audioExtension)
        }
        .onDisappear {
            AudioPlayerManager.shared.stopBackgroundMusic()
            AudioPlayerManager.shared.playBackgroundMusic(named: AudioConstants.introMusic, withExtension: AudioConstants.audioExtension)
        }
        .navigationBarBackButtonHidden(true)
    }

    private func itemButton(for item: CauseEffectItem) -> some View {
        let isActivated = viewModel.activatedIds.contains(item.id)

        return Button {
            viewModel.tap(item)
        } label: {
            VStack(spacing: 8) {
                Image(item.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .opacity(isActivated ? 1.0 : 0.75)
                    .frame(width: 90, height: 90)
                    .background(
                        Circle()
                            .fill(item.color.opacity(isActivated ? 0.25 : 0.12))
                    )
                Text(item.label)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.black.opacity(0.7))
            }
            .frame(width: 130, height: 130)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.9))
            )
            .shadow(radius: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isActivated ? 1.15 : 1.0)
        .rotationEffect(.degrees(isActivated ? 8 : 0))
        .animation(.spring(response: 0.35, dampingFraction: 0.4), value: isActivated)
    }
}
