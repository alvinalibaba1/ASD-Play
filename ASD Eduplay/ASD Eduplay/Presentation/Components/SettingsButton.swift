import SwiftUI

struct SettingsButton: View {
    @EnvironmentObject var router: NavigationRouter

    // Matches the mascot/Play button's own blue instead of a generic
    // system blue, so every "primary action" control on this screen shares
    // one consistent brand color.
    private let buttonColor = Color(red: 0.42, green: 0.78, blue: 0.92)
    private let buttonSize: CGFloat = 60

    var body: some View {
        Button(action: handlePress) {
            VStack(spacing: 6) {
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
                        .padding(15)
                        .foregroundColor(.white)
                }
                .frame(width: buttonSize, height: buttonSize)

                // A bare shadowed label floating directly on the sky
                // background didn't match how every other label in the app
                // sits inside a card or pill - it read as an unfinished
                // afterthought rather than a designed part of the button.
                Text("Settings")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(buttonColor))
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: buttonSize + 20, height: buttonSize + 34)
        .accessibilityLabel("Settings")
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
