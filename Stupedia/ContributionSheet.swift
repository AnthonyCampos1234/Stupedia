//
//  ContributionSheet.swift
//  Stupedia
//
//  Created by Anthony Campos on 10/15/24.
//

import SwiftUI

struct ContributionSheet: View {
    let pageId: UUID
    @Binding var isPresented: Bool
    @State private var newContributionContent = ""
    @State private var pageRating: Int = 0
    let onContributionAdded: () async -> Void
    
    private let maxCharacterCount = 280
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $newContributionContent)
                    .frame(height: 200)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                
                Text("\(newContributionContent.count)/\(maxCharacterCount)")
                    .foregroundColor(newContributionContent.count > maxCharacterCount ? .red : .gray)
                
                Text("Rate this page:")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                StarRating(rating: Double(pageRating), color: .yellow, fillColor: .blue, onTap: { rating in
                    pageRating = rating
                })
                .padding()
                
                Button("Submit Contribution and Rating") {
                    submitContribution()
                }
                .disabled(newContributionContent.isEmpty || newContributionContent.count > maxCharacterCount || pageRating == 0)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            .navigationTitle("Add Contribution")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }
    
    private func submitContribution() {
        Task {
            do {
                try await SupabaseManager.shared.addContribution(pageId: pageId, content: newContributionContent, rating: Double(pageRating))
                await onContributionAdded()
                isPresented = false
            } catch {
                print("Error submitting contribution: \(error)")
            }
        }
    }
}
