//
//  SwiftUIView.swift
//  ASD Eduplay
//
//  Created by Alvin Reyvaldo on 20/02/25.
//

import SwiftUI

struct InteractionBlocker: ViewModifier {
    
    let isBlocking: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isBlocking {
                Color.black.opacity(0.01)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {}
                    .gesture(DragGesture())
                    .gesture(MagnificationGesture())
                    .gesture(RotationGesture())
                    .contentShape(Rectangle())
                    .allowsHitTesting(true)
                    .zIndex(1000)
            }
        }
        .gesture(
            isBlocking ?
            DragGesture(minimumDistance: 0).onChanged { _ in } :
                nil
        )
        .navigationBarBackButtonHidden(isBlocking)
    }
}


extension View {
    func blockInteractions(when condition: Bool) -> some View {
        self.modifier(InteractionBlocker(isBlocking: condition))
    }
}
