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
    @Binding var ticketCount: Int
    @Binding var isSearchActive: Bool
    @Binding var contributionCount: Int
    @FocusState private var isSearchFieldFocused: Bool
    @State private var searchResults: [Page] = []
    @State private var selectedPage: Page?
    @State private var isLoading = false
    @State private var showingCreatePageAlert = false
    @State private var showingDisambiguationAlert = false
    @State private var disambiguationText = ""
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                searchBar
                    .padding(.top, 10)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if !searchResults.isEmpty {
                    resultsList
                } else if !searchText.isEmpty {
                    noResultsView
                } else {
                    placeholderContent
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.isSearchFieldFocused = true
                }
            } else {
                self.isSearchFieldFocused = false
            }
        }
        .alert("Create New Page", isPresented: $showingCreatePageAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Create") { createNewPage() }
        } message: {
            Text("No page found for '\(searchText)'. Would you like to create a new page?")
        }
        .alert("Disambiguation Needed", isPresented: $showingDisambiguationAlert) {
            TextField("Enter disambiguation", text: $disambiguationText)
            Button("Cancel", role: .cancel) { }
            Button("Create") { createNewPage(withDisambiguation: true) }
        } message: {
            Text("A page with the name '\(searchText)' already exists. Please provide additional information to distinguish this new page.")
        }
        .sheet(item: $selectedPage) { page in
            PageView(page: page, ticketCount: $ticketCount, contributionCount: $contributionCount)
        }
    }
    
    private var searchBar: some View {
        TextField("Search...", text: $searchText)
            .focused($isSearchFieldFocused)
            .font(.system(size: 28))
            .foregroundColor(.white)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.none)
            .submitLabel(.search)
            .onSubmit {
                performSearch()
            }
    }
    
    private var resultsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(searchResults) { page in
                    Button(action: { selectedPage = page }) {
                        VStack(alignment: .leading) {
                            Text(page.name)
                                .font(.system(size: 28))
                                .foregroundColor(.black)
                            if let disambiguation = page.disambiguation {
                                Text(disambiguation)
                                    .font(.system(size: 18))
                                    .foregroundColor(.gray)
                            }
                            Text("Rating: \(String(format: "%.1f", page.rating))/5.0")
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                            Text("\(page.contributionCount) contributions")
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    private var noResultsView: some View {
        VStack {
            Text("No results found for '\(searchText)'")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Button("Create New Page") {
                showingCreatePageAlert = true
            }
            .font(.system(size: 20))
            .foregroundColor(.blue)
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var placeholderContent: some View {
        VStack(spacing: 24) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.white)
            Text("Search for pages or create new ones")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func performSearch() {
        isLoading = true
        Task {
            do {
                searchResults = try await SupabaseManager.shared.searchPages(query: searchText)
                if searchResults.isEmpty {
                    showingCreatePageAlert = true
                }
            } catch {
                print("Error searching pages: \(error)")
                searchResults = []
            }
            isLoading = false
        }
    }
    
    private func createNewPage(withDisambiguation: Bool = false) {
        Task {
            do {
                let newPage: Page
                if withDisambiguation {
                    newPage = try await SupabaseManager.shared.createPage(name: searchText, disambiguation: disambiguationText)
                } else {
                    let existingPages = try await SupabaseManager.shared.searchPages(query: searchText)
                    if existingPages.contains(where: { $0.name.lowercased() == searchText.lowercased() }) {
                        showingDisambiguationAlert = true
                        return
                    }
                    newPage = try await SupabaseManager.shared.createPage(name: searchText)
                }
                searchResults = [newPage]
                selectedPage = newPage
            } catch {
                print("Error creating new page: \(error)")
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SearchView(searchText: .constant(""), isActive: .constant(true), buttonIcon: .constant("magnifyingglass"), ticketCount: .constant(5), isSearchActive: .constant(false), contributionCount: .constant(0))
                .previewDevice("iPhone 14")
                .preferredColorScheme(.light)
            
            SearchView(searchText: .constant("Example Search"), isActive: .constant(true), buttonIcon: .constant("magnifyingglass"), ticketCount: .constant(5), isSearchActive: .constant(false), contributionCount: .constant(0))
                .previewDevice("iPhone 14")
                .preferredColorScheme(.dark)
        }
    }
}
