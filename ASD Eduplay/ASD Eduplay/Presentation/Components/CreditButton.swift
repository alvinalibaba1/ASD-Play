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

    private let accentColor = Color.purple

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // A plain text pill didn't match the icon+label pattern every
                // other button in the app uses (see CompactMenuButton), so it
                // read as a stray label rather than an obviously tappable button.
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(accentColor)
                            .shadow(color: accentColor.opacity(0.4), radius: 4, x: 0, y: 2)
                    )

                Text(title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.black.opacity(0.8))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(accentColor, lineWidth: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
    }
}
