//
//  ReviewCell.swift
//  Stupedia
//
//  Created by Anthony Campos on 10/7/24.
//

import SwiftUI

struct ReviewCell: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(review.content)
                .multilineTextAlignment(.leading)
                .foregroundColor(Color(hex: "#4b4b4b"))
            Text(review.timestamp)
                .font(.caption)
                .foregroundColor(Color(hex: "#4b4b4b"))
        }
        
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#f7f7f7"))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(hex: "#4b4b4b")),
            alignment: .bottom
        )
    }
}

#Preview {
    ReviewCell(review: Review(content: "This is a sample review content.", timestamp: "2h ago"))
}


