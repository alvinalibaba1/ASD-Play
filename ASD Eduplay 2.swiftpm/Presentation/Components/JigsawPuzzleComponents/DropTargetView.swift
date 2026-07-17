import SwiftUI

struct DropTargetView: View {
    let row: Int
    let col: Int
    let isTargeted: Bool
    let pieceSize: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .border(isTargeted ? Color.green : Color.blue.opacity(0.3),
                   width: isTargeted ? 3 : 1)
            .frame(width: pieceSize, height: pieceSize)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isTargeted ? Color.green : Color.blue.opacity(0.3),
                           style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .opacity(isTargeted ? 1 : 0.5)
            )
            .animation(.easeInOut(duration: 0.2), value: isTargeted)
    }
}
