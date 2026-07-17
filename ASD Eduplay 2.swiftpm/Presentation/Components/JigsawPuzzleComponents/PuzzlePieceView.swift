import SwiftUI

struct PuzzlePieceView: View {
    let imageName: String
    let row: Int
    let col: Int
    let pieceSize: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: pieceSize * CGFloat(2), height: pieceSize * CGFloat(2))
                .position(x: -CGFloat(col) * pieceSize + pieceSize,
                         y: -CGFloat(row) * pieceSize + pieceSize)
                .clipped()
        }
        .frame(width: pieceSize, height: pieceSize)
        .background(Color.white)
        .border(Color.black, width: 1)
        .animation(nil, value: UUID())
    }
}
