//
//  SwiftUIView.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 21/02/25.
//

import SwiftUI

struct CreditView: View {
    @EnvironmentObject var router: NavigationRouter

    private let creditItems = [
        CreditItem(title: "Graphics Assets", items: [
            "Jigsaw illustrations from Canva Team Pro",
            "Fruit illustration from Canva Team Pro",
            "Object illustration from Canva Team Pro",
            "Background art made with Canva Team Pro"
        ]),
        CreditItem(title: "Sound Effects", items: [
            "Intro Music by DvirSilver from Pixabay",
            "Game Music by samuel Lee from Pixabay",
            "tapButton sound from ZapSplat"
        ]),
        CreditItem(title: "Created By", items: [
            "Alvin Reyvaldo"
        ])
    ]

    var body: some View {
        ZStack {
            // Matches MenuView's light Color.white.opacity(0.2) tint instead
            // of the previous Color.blue.opacity(0.45), which was strong
            // enough to flatten the illustration underneath into a nearly
            // solid color block - it looked broken rather than tinted.
            GeometryReader { bgGeometry in
                Image("backgroundMenu")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: bgGeometry.size.width, height: bgGeometry.size.height)
                    .clipped()
            }
            .edgesIgnoringSafeArea(.all)

            Color.white.opacity(0.2)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                HStack {
                    CustomBackButton()
                        .padding(.leading, 20)
                    Spacer()
                }
                .padding(.top, 20)

                // Previously an endless auto-scrolling "movie credits" roll
                // that never paused - there was no way to actually stop and
                // read a line before it scrolled past, which is the opposite
                // of what this audience needs. A plain scroll view instead
                // lets it be read at whatever pace the reader wants.
                ScrollView {
                    VStack(spacing: 24) {
                        HStack(spacing: 10) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 26))

                            Text("Credits")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(.blue)

                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 26))
                        }
                        .padding(.top, 16)

                        ForEach(creditItems) { item in
                            CreditSectionView(creditItem: item)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct CreditSectionView: View {
    let creditItem: CreditItem

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text(creditItem.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.blue)

            // These lines were sized at 24pt with no width awareness, so a
            // longer credit (e.g. "Background illustration i made from Canva
            // Team Pro") wrapped across many lines on a narrow portrait
            // screen and read as excessively long. 16pt fits comfortably
            // more characters per line before wrapping, closer to how
            // attribution text reads elsewhere (small print, not a headline).
            VStack(alignment: .center, spacing: 10) {
                ForEach(creditItem.items, id: \.self) { item in
                    Text(item)
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.9))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .strokeBorder(Color.blue.opacity(0.2), lineWidth: 2)
        )
    }
}

struct CreditItem: Identifiable {
    let id = UUID()
    let title: String
    let items: [String]
}

