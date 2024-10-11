//
//  SearchButton.swift
//  Stupedia
//
//  Created by Anthony Campos on 10/10/24.
//

import SwiftUI

struct SearchButton: View {
    var body: some View {
        Button(action: {
            print("search button tapped.")
        }) {
            ZStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 75, height: 75)
                
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.white)
                    .font(.system(size: 40))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SearchButton()
}
