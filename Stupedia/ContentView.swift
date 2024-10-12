//
//  ContentView.swift
//  Stupedia
//
//  Created by Anthony Campos on 10/4/24.
//

import SwiftUI

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
        @State private var previousScrollOffset: CGFloat = 0
        @State private var showHeader: Bool = true
        @State private var headerHeight: CGFloat = 0

        var body: some View {
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

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        SearchButton()
                            .padding(.trailing, 30)
                            .padding(.bottom, 0)
                            .shadow(color: Color.gray.opacity(0.5), radius: 4, x: 0, y: 2)
                            .accessibilityLabel("Search")
                            .onTapGesture {
                                isPresentingSearch = true
                            }
                            .opacity(showHeader ? 1 : 0.5)
                            .animation(.easeInOut(duration: 0.3), value: showHeader)
                            .allowsHitTesting(true)
                    }
                }
            }
            .background(Color(hex: "#f7f7f7"))
            .edgesIgnoringSafeArea(.top)
            .sheet(isPresented: $isPresentingSearch) {
                SearchView(searchText: $searchText)
            }
        }
        
        private func handleScrollChange(newOffset: CGFloat) {
            let delta = newOffset - previousScrollOffset
            if delta < -10 {
                withAnimation {
                    showHeader = false
                }
            } else if delta > 10 {
                withAnimation {
                    showHeader = true
                }
            }
            previousScrollOffset = newOffset
        }
        
        var headerView: some View {
            VStack(spacing: 0) {
                Text("Stupedia")
                    .font(.largeTitle)
                    .foregroundColor(Color.black)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(hex: "#f7f7f7"))
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
            }
        }
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

    #Preview {
        ContentView()
    }






