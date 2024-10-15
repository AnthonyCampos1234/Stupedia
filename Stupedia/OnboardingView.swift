//
//  OnboardingView.swift
//  Stupedia
//
//  Created by Anthony Campos on 10/14/24.
//

import SwiftUI
import Supabase

struct OnboardingView: View {
    @Binding var isAuthenticated: Bool
    @State private var phoneNumber = ""
    @State private var confirmationCode = ""
    @State private var isEnteringCode = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @FocusState private var isInputFocused: Bool
    @State private var appearCount = 0  // State to trigger focus
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Text(isEnteringCode ? "Enter the code we texted you" : "Enter your phone number")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 100)
                    
                    ZStack {
                        inputField(for: .phoneNumber)
                            .offset(x: isEnteringCode ? -geometry.size.width : 0)
                        
                        inputField(for: .verificationCode)
                            .offset(x: isEnteringCode ? 0 : geometry.size.width)
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0), value: isEnteringCode)
                    
                    Spacer()
                    
                    actionButton
                }
                .padding()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            appearCount += 1
        }
        .onChange(of: appearCount) {
            isInputFocused = true
        }
        .task {
            await clearExistingSession()
        }
    }
    
    private func inputField(for field: InputField) -> some View {
        Group {
            switch field {
            case .phoneNumber:
                TextField("Phone Number", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .focused($isInputFocused)
                    .opacity(isEnteringCode ? 0 : 1)
            case .verificationCode:
                TextField("Verification Code", text: $confirmationCode)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .focused($isInputFocused)
                    .opacity(isEnteringCode ? 1 : 0)
            }
        }
        .foregroundColor(.white)
        .font(.system(size: 28))
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
    }
    
    private var actionButton: some View {
        Button(action: {
            hapticFeedback()
            if isEnteringCode {
                confirmCode()
            } else {
                sendCode()
            }
        }) {
            HStack {
                Text(isEnteringCode ? "Confirm" : "Send")
                .font(.system(size: 28, weight: .bold))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
        }
        .padding(.horizontal, 20)
        .buttonStyle(PlainButtonStyle())
    }
    
    private func clearExistingSession() async {
        do {
            try await SupabaseManager.shared.signOut()
        } catch {
            print("Error clearing existing session: \(error)")
        }
    }
    
    private func sendCode() {
        let cleanNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let formattedNumber = "+1" + cleanNumber // Assuming US numbers. Adjust if needed.
        
        guard formattedNumber.count == 12 else {
            showAlert = true
            alertMessage = "Invalid phone number format. Please enter a 10-digit US phone number."
            return
        }
        
        Task {
            do {
                try await SupabaseManager.shared.signUp(phoneNumber: formattedNumber)
                withAnimation {
                    isEnteringCode = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isInputFocused = true
                }
            } catch {
                handleError(error)
            }
        }
    }
    
    private func confirmCode() {
        Task {
            do {
                let cleanNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                let formattedNumber = "+1" + cleanNumber
                let session = try await SupabaseManager.shared.verifyOTP(phoneNumber: formattedNumber, token: confirmationCode)
                print("Successfully verified OTP. Session: \(session)")
                isAuthenticated = true
            } catch {
                handleError(error)
            }
        }
    }
    
    private func handleError(_ error: Error) {
        showAlert = true
        if let supabaseError = error as? SupabaseManagerError {
            switch supabaseError {
            case .signUpFailed(let details):
                alertMessage = "Error details: \(details)"
            case .noSessionReturned:
                alertMessage = "Error: No session returned after OTP verification"
            }
        } else {
            alertMessage = "Unknown error: \(error.localizedDescription)"
        }
        print("Error in OnboardingView: \(alertMessage)")
    }
    
    private func hapticFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    private enum InputField {
        case phoneNumber
        case verificationCode
    }
}

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .foregroundColor(.white)
                .font(.system(size: 20))
                .padding(.vertical, 8)
            
            Divider()
                .background(Color.gray.opacity(0.5))
        }
    }
}
