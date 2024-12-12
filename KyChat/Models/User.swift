//
//  User.swift
//  KyChat
//
//  Created by Rizky Azmi Swandy on 11/12/24.
//
struct User: Identifiable, Codable {
    let id: String
    let username: String
}

struct LoginRequest: Codable {
    let username: String
    let password: String
}
