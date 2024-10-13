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
        Review(content: "This guy is actually kind of cool.", timestamp: "1d ago"),
        Review(content: "Yo this kid is lowk stupid.", timestamp: "2h ago"),
        Review(content: "This guy saved 10 children oml!", timestamp: "5h ago"),
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
    ]
    @State private var isPresentingSearch = false
    @State public var searchText = ""
    @State private var scrollOffset: CGFloat = 0
    @State private var previousScrollOffset: CGFloat = 0
    @State private var showHeader: Bool = true
    @State private var headerHeight: CGFloat = 0
    @State private var isSearchActive = false
    @State private var searchButtonOpacity: Double = 1.0
    @State private var ticketCount: Int = 0
    @State private var buttonIcon: String = "magnifyingglass"

    var body: some View {
        ZStack {
            mainView
                .offset(x: isSearchActive ? -UIScreen.main.bounds.width : 0)
            
            SearchView(searchText: $searchText, isActive: $isSearchActive, buttonIcon: $buttonIcon)
                .offset(x: isSearchActive ? 0 : UIScreen.main.bounds.width)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ActionButton(icon: $buttonIcon, action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isSearchActive.toggle()
                            buttonIcon = isSearchActive ? "arrow.left" : "magnifyingglass"
                        }
                    })
                }
                .padding(.trailing, 30)
                .padding(.bottom, 20)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isSearchActive)
    }
    
    private var mainView: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 0) {
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
                    }
                    .frame(height: 50)
                    
                    ForEach(reviews) { review in
                        ReviewCell(review: review)
                            .padding(.horizontal)
                            .padding(.vertical, 1)
                    }
                }
                .padding(.top, headerHeight)
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                handleScrollChange(newOffset: value)
            }
            
            headerView
                .background(GeometryReader { geometry in
                    Color.clear.preference(key: ViewHeightKey.self, value: geometry.size.height)
                })
                .onPreferenceChange(ViewHeightKey.self) { height in
                    self.headerHeight = height
                }
                .offset(y: showHeader ? 40 : -headerHeight)
                .animation(.easeInOut(duration: 0.1), value: showHeader)
        }
        .background(Color(.black))
        .edgesIgnoringSafeArea(.top)
    }
    
    private func handleScrollChange(newOffset: CGFloat) {
        let delta = newOffset - previousScrollOffset
        if delta < -10 {
            withAnimation {
                showHeader = false
                searchButtonOpacity = 0.3 // Lower opacity when scrolling down
            }
        } else if delta > 10 {
            withAnimation {
                showHeader = true
                searchButtonOpacity = 1.0 // Full opacity when scrolling up
            }
        }
        previousScrollOffset = newOffset
    }
    
    var headerView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Stupedia")
                    .font(.largeTitle)
                    .foregroundColor(Color(hex: "1ABC9C"))
                    .fontWeight(.bold)
                Spacer()
                HStack(spacing: 5) {
                    Image(systemName: "ticket.fill")
                        .foregroundColor(Color(hex: "1ABC9C"))
                    Text("\(ticketCount)")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
                .padding(.trailing, 10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.black))
            .shadow(color: Color.white.opacity(0.15), radius: 7, x: 0, y: 2)
        }
    }
    
    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 8)
            
            TextField("Search...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(28)
                .onTapGesture {
                    withAnimation {
                        isSearchActive = true
                    }
                }
            
            if isSearchActive {
                Button("Cancel") {
                    withAnimation {
                        isSearchActive = false
                        searchText = ""
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
                .foregroundColor(Color(hex: "1ABC9C"))
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut, value: isSearchActive)
    }
    
    struct ScrollOffsetPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
    
    struct ViewHeightKey: PreferenceKey {
        static var defaultValue: CGFloat { 0 }
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
}

    #Preview {
        ContentView()
    }






