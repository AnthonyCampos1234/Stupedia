//
//  SupabaseManager.swift
//  Stupedia
//
//  Created by Anthony Campos on 10/14/24.
//

import Foundation
import Supabase

enum SupabaseManagerError: Error {
    case signUpFailed(String)
    case noSessionReturned
}

class SupabaseManager {
    static let shared = SupabaseManager()
    
    private let client: SupabaseClient
    
    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://htadrnjnjeagznxdklws.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh0YWRybmpuamVhZ3pueGRrbHdzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjg5NTE0MTMsImV4cCI6MjA0NDUyNzQxM30.jL80uZ6YffnNMcQa1ds1SxC8IUTj0ftMMrxejrmy_QE"
        )
    }
    
    func signUp(phoneNumber: String) async throws {
        let formattedNumber = phoneNumber.starts(with: "+") ? phoneNumber : "+1\(phoneNumber)"
        print("Attempting to sign up with formatted number: \(formattedNumber)")
        
        do {
            print("Calling client.auth.signInWithOTP")
            try await client.auth.signInWithOTP(
                phone: formattedNumber
            )
            print("OTP sign-in request successful")
        } catch {
            let nsError = error as NSError
            let errorDetails = """
            Domain: \(nsError.domain)
            Code: \(nsError.code)
            Description: \(nsError.localizedDescription)
            User Info: \(nsError.userInfo)
            Underlying Error: \(String(describing: nsError.userInfo[NSUnderlyingErrorKey]))
            """
            print("Detailed error during signUp: \(errorDetails)")
            throw SupabaseManagerError.signUpFailed(errorDetails)
        }
    }
    
    func verifyOTP(phoneNumber: String, token: String) async throws -> Session {
        do {
            let response = try await client.auth.verifyOTP(
                phone: phoneNumber,
                token: token,
                type: .sms
            )
            guard let session = response.session else {
                throw SupabaseManagerError.noSessionReturned
            }
            return session
        } catch {
            let nsError = error as NSError
            let errorDetails = """
            Domain: \(nsError.domain)
            Code: \(nsError.code)
            Description: \(nsError.localizedDescription)
            User Info: \(nsError.userInfo)
            """
            print("Detailed error during OTP verification: \(errorDetails)")
            throw SupabaseManagerError.signUpFailed(errorDetails)
        }
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    func isAuthenticated() async -> Bool {
        do {
            let session = try await client.auth.session
            return session != nil
        } catch {
            print("Error checking authentication status: \(error)")
            return false
        }
    }
    
    struct Profile: Codable {
        let id: String
        let phoneNumber: String
        let ticketCount: Int
        let contributionCount: Int
        
        enum CodingKeys: String, CodingKey {
            case id
            case phoneNumber = "phone_number"
            case ticketCount = "ticket_count"
            case contributionCount = "contribution_count"
        }
    }
    
    func createProfile(id: UUID, phoneNumber: String) async throws {
        let profile = Profile(
            id: id.uuidString,
            phoneNumber: phoneNumber,
            ticketCount: 5,
            contributionCount: 0
        )
        
        try await client.from("profiles")
            .insert(profile)
            .execute()
    }
    
    func getProfile(id: UUID) async throws -> Profile {
        let response: [Profile] = try await client.from("profiles")
            .select()
            .eq("id", value: id.uuidString)
            .execute()
            .value
        
        guard let profile = response.first else {
            throw NSError(domain: "SupabaseManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Profile not found"])
        }
        
        return profile
    }
    
    func signUpWithEmail(email: String, password: String) async throws {
        do {
            let response = try await client.auth.signUp(email: email, password: password)
            print("Sign up response: \(response)")
        } catch {
            let nsError = error as NSError
            let errorDetails = """
            Domain: \(nsError.domain)
            Code: \(nsError.code)
            Description: \(nsError.localizedDescription)
            User Info: \(nsError.userInfo)
            Underlying Error: \(String(describing: nsError.userInfo[NSUnderlyingErrorKey]))
            """
            print("Detailed error during email signUp: \(errorDetails)")
            throw SupabaseManagerError.signUpFailed(errorDetails)
        }
    }
}

struct Page: Codable, Identifiable {
    let id: UUID
    let name: String
    let disambiguation: String?
    let rating: Double  // Change this to Double
    let contributionCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name, disambiguation, rating
        case contributionCount = "contribution_count"
    }
}

extension SupabaseManager {
    func searchPages(query: String) async throws -> [Page] {
        let response: [Page] = try await client.from("pages")
            .select()
            .ilike("name", value: "%\(query)%")
            .order("name")
            .execute()
            .value
        
        return response
    }
    
    func createPage(name: String, disambiguation: String? = nil) async throws -> Page {
        let newPage = Page(id: UUID(), name: name, disambiguation: disambiguation, rating: 0, contributionCount: 0)
        
        let response: Page = try await client.from("pages")
            .insert(newPage)
            .single()
            .execute()
            .value
        
        return response
    }
    
    func getPage(id: UUID) async throws -> Page? {
        let pages: [Page] = try await client
            .from("pages")
            .select()
            .eq("id", value: id.uuidString)
            .execute()
            .value

        return pages.first
    }
}

// Move Contribution struct outside of SupabaseManager class
struct Contribution: Identifiable, Codable {
    let id: UUID
    let pageId: UUID
    let content: String
    let rating: Double  // Change this to Double
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case pageId = "page_id"
        case content
        case rating
        case timestamp
    }
}

extension SupabaseManager {
    func getContributions(for pageId: UUID) async throws -> [Contribution] {
        let response: [Contribution] = try await client.from("contributions")
            .select()
            .eq("page_id", value: pageId)
            .order("timestamp", ascending: false)
            .execute()
            .value
        
        return response
    }
    
    func addContribution(pageId: UUID, content: String, rating: Double) async throws {
        let newContribution = Contribution(
            id: UUID(),
            pageId: pageId,
            content: content,
            rating: rating,
            timestamp: Date()
        )
        
        try await client.from("contributions")
            .insert(newContribution)
            .execute()
        
        try await updatePageStats(pageId: pageId)
    }
    
    private func updatePageStats(pageId: UUID) async throws {
        let contributions: [Contribution] = try await getContributions(for: pageId)
        let totalRating = contributions.reduce(0.0) { $0 + $1.rating }
        let averageRating = contributions.isEmpty ? 0.0 : totalRating / Double(contributions.count)
        
        try await client.from("pages")
            .update([
                "rating": AnyJSON(averageRating),
                "contribution_count": AnyJSON(contributions.count)
            ] as [String: AnyJSON])
            .eq("id", value: pageId)
            .execute()
    }
}

extension SupabaseManager {
    func addRating(pageId: UUID, rating: Int) async throws {
        let session = try await client.auth.session
        let userId = session.user.id
        
        // Insert or update the rating
        try await client
            .from("ratings")
            .upsert([
                "user_id": userId.uuidString,
                "page_id": pageId.uuidString,
                "rating": String(rating)  // Convert Int to String
            ])
            .execute()
        
        // Update the page's average rating
        try await updatePageAverageRating(pageId: pageId)
    }
    
    private func updatePageAverageRating(pageId: UUID) async throws {
        // Get all ratings for the page
        let ratings: [String] = try await client
            .from("ratings")
            .select("rating")
            .eq("page_id", value: pageId.uuidString)
            .execute()
            .value
        
        // Convert ratings from strings to integers and calculate the average
        let intRatings = ratings.compactMap { Int($0) }
        let averageRating = intRatings.isEmpty ? 0.0 : Double(intRatings.reduce(0, +)) / Double(intRatings.count)
        
        // Update the page with the new average rating
        try await client
            .from("pages")
            .update(["rating": averageRating])
            .eq("id", value: pageId.uuidString)
            .execute()
    }
    
    func getUserRating(pageId: UUID) async throws -> Int? {
        let session = try await client.auth.session
        let userId = session.user.id
        
        let ratings: [String] = try await client
            .from("ratings")
            .select("rating")
            .eq("user_id", value: userId.uuidString)
            .eq("page_id", value: pageId.uuidString)
            .execute()
            .value
        
        return ratings.first.flatMap { Int($0) }
    }
}

extension SupabaseManager {
    func getAllContributions() async throws -> [Contribution] {
        let response: [Contribution] = try await client.from("contributions")
            .select()
            .order("timestamp", ascending: false)
            .execute()
            .value
        
        return response
    }
}
