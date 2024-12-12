//
//  APIService.swift
//  KyChat
//
//  Created by Rizky Azmi Swandy on 11/12/24.
//

import Foundation

class APIService {
    static let shared = APIService()
    
    let baseURL = Configuration.baseURL
    private init() {}
    
    func login(username: String, password: String) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/login") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginRequest = ["username": username, "password": password]
        request.httpBody = try? JSONEncoder().encode(loginRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 200 {
            let tokenResponse = try JSONDecoder().decode([String: String].self, from: data)
            if let token = tokenResponse["token"] {
                return LoginResponse(token: token)
            }
        }
        
        throw URLError(.badServerResponse)
    }
}
