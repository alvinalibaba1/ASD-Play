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

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(accentColor))

                Text(title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.black.opacity(0.8))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Spacer(minLength: 0)
            }
            .padding(.leading, 14)
            .padding(.trailing, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.9))
            )
            // Without this, the icon circle (sized close to the pill's own
            // height) visually bulged past the rounded corner instead of
            // being cleanly contained by it - the background's rounded rect
            // doesn't clip its siblings on its own, so anything sitting near
            // a corner can poke out past the curve unless explicitly clipped
            // to the same shape.
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(accentColor, lineWidth: 3)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
    }
}
