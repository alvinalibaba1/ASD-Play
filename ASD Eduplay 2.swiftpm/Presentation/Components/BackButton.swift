import SwiftUI

struct CustomBackButton: View {
    @EnvironmentObject var router: NavigationRouter
    
    @State private var isPressed = false
    @State private var bounceScale: CGFloat = 1.0
    @State private var rotationAngle: Double = 0
    
    private let buttonColor = Color.blue.opacity(0.7)
    private let buttonSize: CGFloat = 75
    private let shadowRadius: CGFloat = 12
    
    var body: some View {
        Button(action: handlePress) {
            ZStack {
                Circle()
                    .fill(buttonColor)
                    .shadow(
                        color: buttonColor.opacity(0.5),
                        radius: shadowRadius,
                        x: 0,
                        y: isPressed ? 2 : 4
                    )
                
                Circle()
                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    .blur(radius: 1)
                
                Image(systemName: "arrow.backward.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(15)
                    .foregroundColor(.white)
            }
            .frame(width: buttonSize, height: buttonSize)
            .scaleEffect(isPressed ? 0.92 : bounceScale)
            .rotationEffect(.degrees(rotationAngle))
            .offset(y: isPressed ? 2 : -1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: rotationAngle)
            .animation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true),
                value: bounceScale
            )
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: buttonSize + 20, height: buttonSize + 20)
        .accessibilityLabel("Go back")
        
    }
    
    private func handlePress() {
        Haptic.shared.success()

        AudioPlayerManager.shared.playAudio(named: "tapButton", withExtension: "mp3")
        isPressed = true
        withAnimation(.default) { rotationAngle = -15 }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.default) { rotationAngle = 0 }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPressed = false 
            router.navigateBack()
        }
    }

}

struct SimplifiedKidBackButton_Previews: PreviewProvider {
    static var previews: some View {
        CustomBackButton()
            .padding(50)
            .previewLayout(.sizeThatFits)
    }
}
