import SwiftUI

struct ProgressButton: View {
    @EnvironmentObject var router: NavigationRouter

    // Orange instead of the old purple, which didn't relate to any other
    // color on the home screen. Blue (Play/Settings) reads as "go do
    // something"; orange (Progress/Credit) reads as "go look something up" -
    // a deliberate two-color system instead of an arbitrary third hue.
    private let buttonColor = Color.orange
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

                    Image(systemName: "chart.bar.fill")
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
                Text("Progress")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(buttonColor))
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: buttonSize + 20, height: buttonSize + 34)
        .accessibilityLabel("Progress")
        .accessibilityHint("See sessions, rounds and accuracy for each game")
    }

    private func handlePress() {
        Haptic.shared.tap()
        AudioPlayerManager.shared.playAudio(
            named: "tapButton",
            withExtension: AudioConstants.audioExtension
        )
        router.navigate(to: .progressSummary)
    }
}
