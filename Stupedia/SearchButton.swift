//
//  SearchButton.swift
//  Stupedia
//
//  Created by Anthony Campos on 10/10/24.
//

import SwiftUI

struct SearchButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color(hex: "1ABC9C"))
                    .frame(width: 70, height: 70)
                
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.white)
                    .font(.system(size: 32))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}


