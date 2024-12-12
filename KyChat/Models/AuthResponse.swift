//
//  AuthResponse.swift
//  KyChat
//
//  Created by Rizky Azmi Swandy on 11/12/24.
//

struct LoginResponse: Codable {
    let token: String
    // Since the server only returns token, we'll derive userId from it
    var userId: String {
        return token // Using token as userId for now
    }
}
