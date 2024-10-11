//
//  SearchView.swift
//  Stupedia
//
//  Created by Anthony Campos on 10/10/24.
//

import SwiftUI

struct SearchView: View {
    var body: some View {
        VStack {
            HStack {
                TextField("Search...", text: $searchText)
                    .padding
            }
        }
    }
}

#Preview {
    SearchView()
}
