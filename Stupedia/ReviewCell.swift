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
                .font(.body)
                .foregroundColor(Color(hex: "#4b4b4b"))
                .multilineTextAlignment(.leading)
            
            Text(review.timestamp)
                .font(.caption)
                .foregroundColor(Color(hex: "#8e8e93"))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(hex: "#ffffff"))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .padding(.vertical, 4) 
    }
}

struct ReviewCell_Previews: PreviewProvider {
    static var previews: some View {
        ReviewCell(review: Review(content: "This is a sample review content.", timestamp: "2h ago"))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}


