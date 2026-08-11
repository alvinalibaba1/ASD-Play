import SwiftUI

struct SettingsButton: View {
    @EnvironmentObject var router: NavigationRouter

    private let buttonColor = Color.blue.opacity(0.7)
    private let buttonSize: CGFloat = 75

    var body: some View {
        Button(action: handlePress) {
            ZStack {
                Circle()
                    .fill(buttonColor)
                    .shadow(color: buttonColor.opacity(0.5), radius: 12, x: 0, y: 4)

                Circle()
                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    .blur(radius: 1)

                Image(systemName: "gearshape.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(18)
                    .foregroundColor(.white)
            }
            .frame(width: buttonSize, height: buttonSize)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: buttonSize + 20, height: buttonSize + 20)
        .accessibilityLabel("Sensory settings")
        .accessibilityHint("Adjust music, sound, vibration and movement")
    }

    private func handlePress() {
        Haptic.shared.tap()
        AudioPlayerManager.shared.playAudio(
            named: "tapButton",
            withExtension: AudioConstants.audioExtension
        )
        router.navigate(to: .sensorySettings)
    }
}
