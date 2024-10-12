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
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (0, 0, 0, 0)
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
        
        @State private var scrollOffset: CGFloat = 0
        @State private var lastScrollOffset: CGFloat = 0
        @State private var headerVisible: Bool = true

        var body: some View {
            ZStack(alignment: .bottomTrailing) {
                NavigationView {
                    VStack(spacing: 0) {
                        // Header
                        if headerVisible {
                            headerView
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .animation(.easeInOut, value: headerVisible)
                        }
                        
                        // Scrollable Content
                        TrackableScrollView(scrollOffset: $scrollOffset) {
                            LazyVStack(spacing: 0) {
                                ForEach(reviews) { review in
                                    ReviewCell(review: review)
                                        .padding(.horizontal)
                                        .padding(.vertical, 5)
                                }
                            }
                        }
                        .onChange(of: scrollOffset) { newValue in
                            let delta = newValue - lastScrollOffset
                            if delta < -10 {
                                // Scrolling Up
                                withAnimation {
                                    headerVisible = true
                                }
                            } else if delta > 10 {
                                // Scrolling Down
                                withAnimation {
                                    headerVisible = false
                                }
                            }
                            lastScrollOffset = newValue
                        }
                    }
                    .navigationBarHidden(true)
                    .background(Color(hex: "#f7f7f7"))
                }
                
                // Search Button
                SearchButton()
                    .padding(.trailing, 30)
                    .shadow(color: Color.gray.opacity(0.5), radius: 4, x: 0, y: 2)
                    .accessibilityLabel("Search")
                    .onTapGesture {
                        isPresentingSearch = true
                    }
                    .sheet(isPresented: $isPresentingSearch) {
                        SearchView(searchText: $searchText)
                    }
            }
        }
        
        // Header View
        var headerView: some View {
            VStack(spacing: 0) {
                Text("Stupedia")
                    .font(.largeTitle)
                    .foregroundColor(Color.black)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(hex: "#f7f7f7"))
            }
        }
    }

#Preview {
    ContentView()
}




