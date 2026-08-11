import SwiftUI

struct MatchingDropTargetView: View {
    let targetImage: String
    let isTargeted: Bool
    let onFrameChange: (CGRect) -> Void
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(isTargeted ? Color.green : Color.blue, lineWidth: 3)
                .frame(width: 130, height: 130)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .shadow(radius: 5)
                )
                .animation(.easeInOut(duration: 0.2), value: isTargeted)
            
            Image(targetImage)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .opacity(0.5)
        }
        .background(GeometryReader { geometry -> Color in
            let frame = geometry.frame(in: .global)
            onFrameChange(frame)
            return Color.clear
        })
    }
}
