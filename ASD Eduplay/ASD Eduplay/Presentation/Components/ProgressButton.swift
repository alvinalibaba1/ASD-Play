import SwiftUI

struct ProgressButton: View {
    @EnvironmentObject var router: NavigationRouter

    private let buttonColor = Color.purple.opacity(0.7)
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

                Text("Progress")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 1)
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
