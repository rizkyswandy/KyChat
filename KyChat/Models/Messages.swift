//
//  Messages.swift
//  KyChat
//
//  Created by Rizky Azmi Swandy on 11/12/24.
//
import Foundation

struct Message: Identifiable, Codable, Equatable {
    let id: String
    let content: String
    let senderId: String
    let username: String  // Add this to match server
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case senderId
        case username    // Add this
        case timestamp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        senderId = try container.decode(String.self, forKey: .senderId)
        username = try container.decode(String.self, forKey: .username)  // Add this
        
        let timestampString = try container.decode(String.self, forKey: .timestamp)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withTimeZone]
        
        if let date = formatter.date(from: timestampString) {
            timestamp = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .timestamp,
                  in: container,
                  debugDescription: "Date string does not match format")
        }
    }
}
