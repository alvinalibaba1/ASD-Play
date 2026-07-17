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
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Text(title)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 25)   
            .background(
                RoundedRectangle(cornerRadius: 20) 
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
    }
}
