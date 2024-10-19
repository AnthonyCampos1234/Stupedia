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
    @AppStorage("isUserAuthenticated") private var isUserAuthenticated = false
    @State private var contributions: [Contribution] = []
    @State private var isLoading = true
    @State private var searchText = ""
    @State private var isSearchActive = false
    @State private var buttonIcon = "magnifyingglass"
    @State private var ticketCount = 5
    @State private var contributionCount = 0
    @State private var selectedContribution: Contribution?
    @State private var showExpandedContribution = false
    @State private var headerHeight: CGFloat = 0
    @State private var showHeader = true
    @State private var lastScrollPosition: CGFloat = 0
    @State private var refreshTimer: Timer?
    @State private var isRefreshing = false

    var body: some View {
        Group {
            if isUserAuthenticated {
                mainAppView
            } else {
                OnboardingView(isAuthenticated: $isUserAuthenticated)
            }
        }
        .task {
            await checkAuthenticationStatus()
            startRefreshTimer()
        }
        .onDisappear {
            stopRefreshTimer()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            Task {
                await checkAuthenticationStatus()
            }
        }
    }
    
    private func checkAuthenticationStatus() async {
        let authenticated = await SupabaseManager.shared.isAuthenticated()
        DispatchQueue.main.async {
            isUserAuthenticated = authenticated
        }
    }
    
    private var mainAppView: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                mainView
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .offset(x: isSearchActive ? -geometry.size.width : 0)
                
                SearchView(
                    searchText: $searchText,
                    isActive: $isSearchActive,
                    buttonIcon: $buttonIcon,
                    ticketCount: $ticketCount,
                    isSearchActive: $isSearchActive,
                    contributionCount: $contributionCount
                )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .offset(x: isSearchActive ? 0 : geometry.size.width)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ActionButton(icon: $buttonIcon, action: toggleSearch)
                        Button(action: signOut) {
                            Text("Sign Out")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.trailing, 30)
                    .padding(.bottom, 20)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isSearchActive)
    }
    
    private var mainView: some View {
        ZStack(alignment: .top) {
            ScrollView {
                RefreshControl(isRefreshing: $isRefreshing, coordinateSpace: .named("scroll")) {
                    await refreshContributions()
                }
                VStack(spacing: 0) {
                    GeometryReader { geometry in
                        Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).origin.y)
                    }
                    .frame(height: 0)
                    
                    ForEach(contributions) { contribution in
                        ContributionCell(contribution: contribution)
                            .padding(.horizontal)
                            .padding(.vertical, 1)
                            .onTapGesture {
                                selectedContribution = contribution
                                showExpandedContribution = true
                            }
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
                .offset(y: showHeader ? 0 : -headerHeight)
                .animation(.easeInOut(duration: 0.3), value: showHeader)
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $showExpandedContribution) {
            if let contribution = selectedContribution {
                ExpandedContributionView(contribution: contribution, showExpandedContribution: $showExpandedContribution)
            }
        }
        .onAppear {
            Task {
                await loadContributions()
            }
        }
    }
    
    private func refreshContributions() async {
        isRefreshing = true
        await loadContributions()
        isRefreshing = false
    }

    private func loadContributions() async {
        isLoading = true
        do {
            let newContributions = try await SupabaseManager.shared.getAllContributions()
            DispatchQueue.main.async {
                self.contributions = newContributions
                self.isLoading = false
                self.contributionCount = newContributions.count
            }
        } catch {
            print("Error loading contributions: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }

    private var headerView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Stupedia")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                HStack(spacing: 8) {
                    Image(systemName: "ticket.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                    Text("\(ticketCount)")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold))
                }
            }
            .padding(.horizontal)
            .padding(.top, 50)
            .padding(.bottom, 10)
            .background(Color.black)
        }
        .background(Color.black)
        .shadow(color: Color.white.opacity(0.15), radius: 7, x: 0, y: 2)
    }
    
    private func toggleSearch() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isSearchActive.toggle()
            buttonIcon = isSearchActive ? "arrow.left" : "magnifyingglass"
        }
    }
    
    private func signOut() {
        Task {
            do {
                try await SupabaseManager.shared.signOut()
                DispatchQueue.main.async {
                    isUserAuthenticated = false
                }
            } catch {
                print("Error signing out: \(error)")
            }
        }
    }
    
    private func handleScrollChange(newOffset: CGFloat) {
        let delta = newOffset - lastScrollPosition
        lastScrollPosition = newOffset
        
        withAnimation {
            if delta > 0 {
                // Scrolling down
                showHeader = false
            } else if delta < 0 {
                // Scrolling up
                showHeader = true
            }
        }
    }

    private func startRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            Task {
                await loadContributions()
            }
        }
    }

    private func stopRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
}

struct ContributionCell: View {
    let contribution: Contribution
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(contribution.content)
                .font(.system(size: 28))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            HStack {
                StarRating(rating: contribution.rating, color: .yellow)
                Spacer()
                Text(contribution.timestamp, style: .relative)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

struct ExpandedContributionView: View {
    let contribution: Contribution
    @Binding var showExpandedContribution: Bool

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text(contribution.content)
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .padding()

                HStack {
                    StarRating(rating: contribution.rating, color: .yellow)
                    Spacer()
                    Text(contribution.timestamp, style: .date)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                .padding(.horizontal)

                Button(action: {
                    showExpandedContribution = false
                }) {
                    Text("Close")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .background(Color.black)
            .cornerRadius(20)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct RefreshControl: View {
    @Binding var isRefreshing: Bool
    let coordinateSpace: CoordinateSpace
    var onRefresh: () async -> Void

    @State private var progress: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            if geometry.frame(in: coordinateSpace).midY > 50 {
                Spacer()
                    .onAppear {
                        Task {
                            await onRefresh()
                        }
                    }
            } else {
                let pullProgress = min(max(geometry.frame(in: coordinateSpace).midY / 150, 0), 1)
                ProgressView()
                    .scaleEffect(pullProgress)
                    .opacity(pullProgress)
                    .frame(width: geometry.size.width)
            }
        }
        .padding(.top, -50)
    }
}
