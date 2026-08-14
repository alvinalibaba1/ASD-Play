import SwiftUI

/// Brief sparkle burst shown at a piece's board position the instant it's
/// placed correctly - positive feedback on every piece, not only once the
/// whole picture is done.
struct JigsawPieceCelebrationView: View {
    @State private var isExpanded = false

    private let symbols = ["✨", "⭐️", "✨", "⭐️"]
    private let angles: [Double] = [45, 135, 225, 315]

    var body: some View {
        ZStack {
            ForEach(0..<symbols.count, id: \.self) { index in
                Text(symbols[index])
                    .font(.system(size: 22))
                    .offset(
                        x: isExpanded ? CGFloat(cos(angles[index] * .pi / 180)) * 46 : 0,
                        y: isExpanded ? CGFloat(sin(angles[index] * .pi / 180)) * 46 : 0
                    )
                    .opacity(isExpanded ? 0 : 1)
                    .scaleEffect(isExpanded ? 1.3 : 0.4)
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeOut(duration: 0.55)) {
                isExpanded = true
            }
        }
    }
}
