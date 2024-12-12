//
//  Configuration.swift
//  KyChat
//
//  Created by Rizky Azmi Swandy on 12/12/24.
//

import Foundation

struct Configuration {
    static let baseURL: String = {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String else {
            fatalError("BASE_URL not found in plist")
        }
        return baseURL
    }()
    
    static let wsHost: String = {
        guard let host = Bundle.main.object(forInfoDictionaryKey: "WS_HOST") as? String else {
            fatalError("WS_HOST not found in plist")
        }
        return host
    }()
    
    static let wsPort: String = {
        guard let port = Bundle.main.object(forInfoDictionaryKey: "WS_PORT") as? String else {
            fatalError("WS_PORT not found in plist")
        }
        return port
    }()
}
