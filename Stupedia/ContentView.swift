//
//  ContentView.swift
//  Stupedia
//
//  Created by Anthony Campos on 10/4/24.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ContentView: View {
    @State private var reviews = [
        Review(content: "Yo this kid is lowk stupid.", timestamp: "2h ago"),
        Review(content: "This guy saved 10 children oml!", timestamp: "5h ago"),
        Review(content: "This guy is actually kind of cool.", timestamp: "1d ago"),
        Review(content: "Yo this kid is lowk stupid.", timestamp: "2h ago"),
        Review(content: "This guy saved 10 children oml!", timestamp: "5h ago"),
        Review(content: "This guy is actually kind of cool.", timestamp: "1d ago"),
        Review(content: "Yo this kid is lowk stupid.", timestamp: "2h ago"),
        Review(content: "This guy saved 10 children oml!", timestamp: "5h ago"),
        Review(content: "This guy is actually kind of cool.", timestamp: "1d ago"),
        Review(content: "Yo this kid is lowk stupid.", timestamp: "2h ago"),
        Review(content: "This guy saved 10 children oml!", timestamp: "5h ago"),
        Review(content: "This guy is actually kind of cool.", timestamp: "1d ago"),
        Review(content: "Yo this kid is lowk stupid.", timestamp: "2h ago"),
        Review(content: "This guy saved 10 children oml!", timestamp: "5h ago"),
        Review(content: "This guy is actually kind of cool.", timestamp: "1d ago")
    ]
    
    @State private var isPresentingSearch = false
    @State public var searchText = " "
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationView {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Text("Stupedia")
                            .font(.largeTitle)
                            .foregroundColor(Color(hex: "#4b4b4b"))
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(Color(hex: "#4b4b4b")),
                                alignment: .bottom
                            )
                    }
                    .background(Color(hex: "#f7f7f7"))
                    
                    List(reviews) { review in
                        ReviewCell(review: review)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(PlainListStyle())
                }
                .navigationBarHidden(true)
                .background(Color(hex: "#f7f7f7"))
            }
            SearchButton()
                .padding(.trailing, 30)
                .shadow(color: Color.gray.opacity(0.5), radius: 4, x: 0, y: 2)
                .accessibilityLabel("Search")
                .onTapGesture {
                    isPresentingSearch = true
                }
                .sheet(isPresented: $isPresentingSearch){
                    SearchView(searchText: $searchText)
                }
        }
    }
}

#Preview {
    ContentView()
}




