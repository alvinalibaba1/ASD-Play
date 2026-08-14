import SwiftUI

/// Pieces-placed counter shown at the top of the board, so progress toward
/// finishing the current picture is visible at a glance instead of only
/// becoming obvious once every piece is already in.
struct JigsawProgressBadge: View {
    let placed: Int
    let total: Int
    @State private var isBumped = false

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "puzzlepiece.fill")
                .font(.system(size: 14, weight: .semibold))
            Text("\(placed)/\(total)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.blue.opacity(0.85))
                .shadow(radius: 4)
        )
        .scaleEffect(isBumped ? 1.15 : 1.0)
        .onChange(of: placed) { _ in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isBumped = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isBumped = false
                }
            }
        }
    }
}
