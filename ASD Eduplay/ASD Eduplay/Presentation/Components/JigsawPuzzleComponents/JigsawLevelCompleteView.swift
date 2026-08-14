import SwiftUI

/// Celebratory badge shown centered over the board the instant a picture is
/// fully assembled - distinct from JigsawCompletionView's full-screen
/// overlay, which only appears once every picture in the set is finished.
struct JigsawLevelCompleteView: View {
    @State private var isVisible = false

    private let sparkleAngles: [Double] = [0, 45, 90, 135, 180, 225, 270, 315]

    var body: some View {
        ZStack {
            ForEach(0..<sparkleAngles.count, id: \.self) { index in
                Text("✨")
                    .font(.system(size: 20))
                    .offset(
                        x: isVisible ? CGFloat(cos(sparkleAngles[index] * .pi / 180)) * 80 : 0,
                        y: isVisible ? CGFloat(sin(sparkleAngles[index] * .pi / 180)) * 80 : 0
                    )
                    .opacity(isVisible ? 0 : 1)
            }

            Circle()
                .fill(Color.green)
                .frame(width: 92, height: 92)
                .shadow(radius: 10)

            Image(systemName: "checkmark")
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(.white)
        }
        .scaleEffect(isVisible ? 1.0 : 0.4)
        .opacity(isVisible ? 1.0 : 0.0)
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.6)) {
                isVisible = true
            }
        }
    }
}
