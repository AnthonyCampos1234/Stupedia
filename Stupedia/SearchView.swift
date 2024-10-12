//
//  SearchView.swift
//  Stupedia
//
//  Created by Anthony Campos on 10/10/24.
//

import SwiftUI

struct SearchView: View {
    @Binding var searchText: String
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isSearchFieldFocused: Bool

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                            .imageScale(.medium)

                        TextField("Search...", text: $searchText)
                            .focused($isSearchFieldFocused)
                            .font(.system(size: 16))
                            .foregroundColor(Color(.white))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.none)
                            .submitLabel(.search)

                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white)
                                    .imageScale(.medium)
                            }
                            .accessibilityLabel("Clear search text")
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(Color.black)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color(.white), lineWidth: 1)
                    )

                    if isSearchFieldFocused {
                        Button("Cancel") {
                            withAnimation {
                                searchText = ""
                                isSearchFieldFocused = false
                                dismiss()
                            }
                        }
                        .foregroundColor(Color(hex: "1ABC9C"))
                        .transition(.move(edge: .trailing))
                        .animation(.easeInOut, value: isSearchFieldFocused)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)

                Spacer()
            }
        }
        .onTapGesture {
            if isSearchFieldFocused {
                isSearchFieldFocused = false
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    self.isSearchFieldFocused = true
                }
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SearchView(searchText: .constant(""))
                .previewDevice("iPhone 14")
                .preferredColorScheme(.light)
            
            SearchView(searchText: .constant("Example Search"))
                .previewDevice("iPhone 14")
                .preferredColorScheme(.dark)
        }
    }
}
