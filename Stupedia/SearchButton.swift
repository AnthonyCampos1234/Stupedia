//
//  SearchButton.swift
//  Stupedia
//
//  Created by Anthony Campos on 10/10/24.
//

import SwiftUI

struct SearchButton: View {
    @State private var isShowingSearchView = false
    @State private var searchText = ""
    
    var body: some View {
        Button(action: {
            isShowingSearchView = true
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
        .sheet(isPresented: $isShowingSearchView) {
            NavigationView {
                SearchView(searchText: $searchText)
            }
        }
    }
}

#Preview {
    SearchButton()
}
