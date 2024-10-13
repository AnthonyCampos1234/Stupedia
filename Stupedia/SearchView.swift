//
//  SearchView.swift
//  Stupedia
//
//  Created by Anthony Campos on 10/10/24.
//

import SwiftUI

struct SearchView: View {
    @Binding var searchText: String
    @Binding var isActive: Bool
    @Binding var buttonIcon: String
    @FocusState private var isSearchFieldFocused: Bool
    @State private var searchResults: [String] = []
    @State private var keyboardHeight: CGFloat = 0
    @State private var isViewAppeared = false
    
    private let tealColor = Color(hex: "1ABC9C")
    private let backgroundColor = Color.black
    private let textColor = Color.white
    private let secondaryColor = Color.gray
    
    var body: some View {
        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                searchBar
                
                if !searchText.isEmpty {
                    resultsList
                } else {
                    placeholderContent
                }
            }
        }
        .onAppear {
            isViewAppeared = true
            focusSearchField()
        }
        .onChange(of: isActive) { _, newValue in
            if newValue && isViewAppeared {
                focusSearchField()
            }
        }
        .onChange(of: isViewAppeared) { _, newValue in
            if newValue && isActive {
                focusSearchField()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                keyboardHeight = keyboardRectangle.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
    }
    
    private var searchBar: some View {
        HStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(secondaryColor)
                    .imageScale(.medium)
                
                TextField("Search...", text: $searchText)
                    .focused($isSearchFieldFocused)
                    .font(.system(size: 16))
                    .foregroundColor(textColor)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.none)
                    .submitLabel(.search)
                    .onSubmit {
                        performSearch()
                    }
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(secondaryColor)
                            .imageScale(.medium)
                    }
                    .accessibilityLabel("Clear search text")
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(hex: "1E1E1E"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(tealColor.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 20)
        .background(backgroundColor)
    }
    
    private var resultsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(searchResults, id: \.self) { result in
                    HStack {
                        Text(result)
                            .foregroundColor(textColor)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(tealColor)
                            .imageScale(.small)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color(hex: "1E1E1E"))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }
    
    private var placeholderContent: some View {
        VStack(spacing: 24) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(tealColor)
            Text("Search for articles, topics, or keywords")
                .font(.headline)
                .foregroundColor(secondaryColor)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func performSearch() {
        // Simulated search functionality
        // Replace this with actual search logic in a real app
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if !searchText.isEmpty {
                searchResults = [
                    "Result 1 for \(searchText)",
                    "Result 2 for \(searchText)",
                    "Result 3 for \(searchText)",
                    "Result 4 for \(searchText)",
                    "Result 5 for \(searchText)"
                ]
            } else {
                searchResults = []
            }
        }
    }
    
    private func focusSearchField() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isSearchFieldFocused = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SearchView(searchText: .constant(""), isActive: .constant(true), buttonIcon: .constant("magnifyingglass"))
                .previewDevice("iPhone 14")
                .preferredColorScheme(.light)
            
            SearchView(searchText: .constant("Example Search"), isActive: .constant(true), buttonIcon: .constant("magnifyingglass"))
                .previewDevice("iPhone 14")
                .preferredColorScheme(.dark)
        }
    }
}
