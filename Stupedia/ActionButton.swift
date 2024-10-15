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
            hapticFeedback()
            withAnimation(.easeInOut(duration: 0.3)) {
                isRotating.toggle()
            }
            action()
        }) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 70, height: 70)
                
                IconView(icon: icon, isRotating: isRotating)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func hapticFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
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
        .foregroundStyle(Color.black)
        .font(.system(size: 32))
    }
}
