//
//  StupediaApp.swift
//  Stupedia
//
//  Created by Anthony Campos on 10/4/24.
//

import SwiftUI

@main
struct StupediaApp: App {
    @State private var isAuthenticated = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await checkAuthStatus()
                }
        }
    }
    
    func checkAuthStatus() async {
        isAuthenticated = await SupabaseManager.shared.isAuthenticated()
    }
}
