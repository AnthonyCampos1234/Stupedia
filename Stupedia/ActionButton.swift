//
//  ActionButton.swift
//  Stupedia
//
//  Created by Anthony Campos on 10/12/24.
//

import SwiftUI

struct ActionButton: View {
    @Binding var icon: String
    let action: () -> Void
    
    @State private var isRotating = false
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                isRotating.toggle()
            }
            action()
        }) {
            ZStack {
                Circle()
                    .fill(Color(hex: "1E90FF"))
                    .frame(width: 70, height: 70)
                
                IconView(icon: icon, isRotating: isRotating)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct IconView: View {
    let icon: String
    let isRotating: Bool
    
    var body: some View {
        ZStack {
            Image(systemName: "magnifyingglass")
                .opacity(icon == "magnifyingglass" ? 1 : 0)
                .rotationEffect(.degrees(isRotating ? -90 : 0))
            Image(systemName: "arrow.left")
                .opacity(icon == "arrow.left" ? 1 : 0)
                .rotationEffect(.degrees(isRotating ? 0 : 90))
        }
        .foregroundStyle(Color.white)
        .font(.system(size: 32))
    }
}
