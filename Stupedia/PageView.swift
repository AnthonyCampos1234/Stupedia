//
//  PageView.swift
//  Stupedia
//
//  Created by Anthony Campos on 10/15/24.
//

import SwiftUI

struct PageView: View {
    @State private var page: Page
    @State private var contributions: [Contribution] = []
    @State private var isShowingContributionSheet = false
    @State private var isLoading = false
    @Binding var ticketCount: Int
    @Binding var contributionCount: Int
    
    init(page: Page, ticketCount: Binding<Int>, contributionCount: Binding<Int>) {
        _page = State(initialValue: page)
        _ticketCount = ticketCount
        _contributionCount = contributionCount
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    pageInfoSection
                    addContributionButton
                    contributionsSection
                }
                .padding()
            }
        }
        .navigationTitle(page.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadInitialData()
        }
        .sheet(isPresented: $isShowingContributionSheet) {
            ContributionSheet(
                pageId: page.id,
                isPresented: $isShowingContributionSheet,
                onContributionAdded: {
                    await self.onContributionAdded()
                }
            )
        }
    }
    
    private var pageInfoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Page Info")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(page.name)
                .font(.title)
                .foregroundColor(.white)
            
            if let disambiguation = page.disambiguation {
                Text(disambiguation)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            HStack {
                Text("Average Rating:")
                StarRating(rating: page.rating, color: .yellow)
                Text(String(format: "%.1f", page.rating))  // Add this line to show the numeric rating
            }
            .foregroundColor(.white)
            
            Text("\(page.contributionCount) contributions")
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
    
    private var contributionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Contributions")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if contributions.isEmpty {
                Text("No contributions yet")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(contributions) { contribution in
                    contributionView(contribution)
                }
            }
        }
    }
    
    private func contributionView(_ contribution: Contribution) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(contribution.content)
                .foregroundColor(.white)
            HStack {
                StarRating(rating: Double(contribution.rating), color: .yellow)
                Spacer()
                Text(contribution.timestamp, style: .date)
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
    
    private var addContributionButton: some View {
        Button(action: {
            isShowingContributionSheet = true
        }) {
            Text("Add Contribution")
                .foregroundColor(.blue)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
        }
    }
    
    private func loadInitialData() async {
        await loadContributions()
    }
    
    private func loadContributions() async {
        isLoading = true
        do {
            contributions = try await SupabaseManager.shared.getContributions(for: page.id)
        } catch {
            print("Error loading contributions: \(error)")
        }
        isLoading = false
    }
    
    private func refreshPageData() async {
        do {
            if let updatedPage = try await SupabaseManager.shared.getPage(id: page.id) {
                page = updatedPage
            }
        } catch {
            print("Error refreshing page data: \(error)")
        }
    }
    
    private func onContributionAdded() async {
        await loadContributions()
        contributionCount += 1
        if contributionCount % 3 == 0 {
            ticketCount += 5
        }
        await refreshPageData()
    }
}

struct StarRating: View {
    let rating: Double
    let color: Color
    var fillColor: Color = .yellow
    var maxRating: Int = 5
    var onTap: ((Int) -> Void)?
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(1...maxRating, id: \.self) { star in
                Image(systemName: "star.fill")
                    .foregroundColor(star <= Int(rating.rounded(.up)) ? fillColor : color.opacity(0.3))
                    .onTapGesture {
                        onTap?(star)
                    }
            }
        }
    }
}
