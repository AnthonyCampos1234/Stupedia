//
//  ReviewListView.swift
//  Stupedia
//
//  Created by Anthony Campos on 10/7/24.
//

import SwiftUI

struct ReviewListView: View {
    let reviews: [Review]
    
    var body: some View {
        List(reviews) { review in
            ReviewCell(review: review)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .listStyle(PlainListStyle())
    }
}

