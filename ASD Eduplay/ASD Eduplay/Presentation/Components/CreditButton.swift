//
//  SwiftUIView.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 21/02/25.
//

import SwiftUI

struct CreditButton: View {
    let title: String
    let action: () -> Void

    // Orange instead of the old purple - ties this "informational" button to
    // ProgressButton's color instead of a shade that didn't relate to
    // anything else on the home screen (which was blue for Play/Settings).
    private let accentColor = Color.orange
    private let buttonSize: CGFloat = 72

    // A wide horizontal pill looked disproportionate sitting under the round
    // Play button and next to the round Progress/Settings buttons - every
    // other control on this screen is a circle. Matching that same
    // icon-circle + label-pill shape (just larger, since Credit is a more
    // prominent home-screen action than the small corner utilities) makes
    // the whole screen read as one consistent shape language instead of one
    // button breaking the pattern.
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(accentColor)
                        .shadow(color: accentColor.opacity(0.5), radius: 12, x: 0, y: 4)

                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                        .blur(radius: 1)

                    Image(systemName: "info.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(18)
                        .foregroundColor(.white)
                }
                .frame(width: buttonSize, height: buttonSize)

                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(accentColor))
            }
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
    }
}
