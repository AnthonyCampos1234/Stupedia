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
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color(hex: "1ABC9C"))
                    .frame(width: 70, height: 70)
                
                Image(systemName: icon)
                    .foregroundStyle(Color.white)
                    .font(.system(size: 32))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

