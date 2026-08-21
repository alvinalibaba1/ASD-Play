//
//  SwiftUIView.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 21/02/25.
//

import SwiftUI

struct CreditView: View {
    @EnvironmentObject var router: NavigationRouter
    
    @State private var scrollOffset: CGFloat = 0
    @State private var isAnimating = false
    @State private var animationWorkItem: DispatchWorkItem?
    
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
            // Flat Color.blue.opacity(0.8) stood out as mismatched against
            // every other screen (Menu, Progress, Settings), which all share
            // the same illustrated backgroundMenu image under a color tint.
            // Using that same image + tint here instead keeps Credits
            // visually consistent with the rest of the app.
            GeometryReader { bgGeometry in
                Image("backgroundMenu")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: bgGeometry.size.width, height: bgGeometry.size.height)
                    .clipped()
            }
            .edgesIgnoringSafeArea(.all)

            Color.blue.opacity(0.45)
                .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    CustomBackButton()
                        .padding(.leading, 20)
                    Spacer()
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .zIndex(1)
            
            GeometryReader { geometry in
                VStack(spacing: 40) {
                    Group {
                        Text("Credits")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 20)
                        
                        ForEach(creditItems) { item in
                            CreditSectionView(creditItem: item)
                        }
                    }
                    
                    Spacer().frame(height: geometry.size.height / 2)
                }
                .padding(.horizontal)
                .offset(y: scrollOffset)
                .drawingGroup()
                .onAppear {
                    scrollOffset = geometry.size.height
                    startContinuousAnimation(screenHeight: geometry.size.height)
                }
            }
        }
        .onDisappear {
            animationWorkItem?.cancel()
            animationWorkItem = nil
        }
        .navigationBarBackButtonHidden(true)
    }

    private func startContinuousAnimation(screenHeight: CGFloat) {
        let contentHeight = CGFloat(creditItems.count * 200) + 400
        let animationDuration: Double = 25


        func animateCycle() {
            withAnimation(.linear(duration: animationDuration)) {
                scrollOffset = -contentHeight
            }

            let workItem = DispatchWorkItem {
                scrollOffset = screenHeight
                animateCycle()
            }

            animationWorkItem = workItem

            DispatchQueue.main.asyncAfter(
                deadline: .now() + animationDuration - 0.1,
                execute: workItem
            )
        }

        animateCycle()
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
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10)
        )
        .drawingGroup()
    }
}

struct CreditItem: Identifiable {
    let id = UUID()
    let title: String
    let items: [String]
}

