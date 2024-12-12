//
//  ContentView.swift
//  KyChat
//
//  Created by Rizky Azmi Swandy on 11/12/24.
//

// View/ContentView.swift
import SwiftUI

struct ContentView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var loginResponse: LoginResponse?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            if let loginResponse = loginResponse {
                ChatView(
                    token: loginResponse.token,
                    username: username,
                    userId: loginResponse.userId
                )
            } else {
                VStack(spacing: 20) {
                    TextField("Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .textInputAutocapitalization(.never)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button(action: login) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Login")
                        }
                    }
                    .disabled(username.isEmpty || password.isEmpty || isLoading)
                }
                .padding()
                .navigationTitle("KyChat")
            }
        }
    }
    
    private func login() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await APIService.shared.login(
                    username: username,
                    password: password
                )
                await MainActor.run {
                    self.loginResponse = response
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Login failed: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
