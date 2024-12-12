//
//  WebsocketManager.swift
//  KyChat
//
//  Created by Rizky Azmi Swandy on 11/12/24.
//
import Foundation

class WebSocketManager: ObservableObject {
    @Published var messages: [Message] = []
    private var webSocket: URLSessionWebSocketTask?
    let userId: String
    let username: String
    
    init(userId: String, username: String) {
        self.userId = userId
        self.username = username
    }
    
    func connect(token: String) {
        guard var urlComponents = URLComponents(string: "ws://\(Configuration.wsHost):\(Configuration.wsPort)/ws") else {
            return
        }
        urlComponents.queryItems = [URLQueryItem(name: "token", value: token)]
        
        guard let url = urlComponents.url else { return }
        print("Connecting to WebSocket at: \(url)")
        
        let session = URLSession(configuration: .default)
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
        
        receiveMessage()
    }
    
    func send(content: String) {
        // Only send the content as expected by the server
        let messageDict = ["content": content]
        
        if let jsonData = try? JSONEncoder().encode(messageDict),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("Sending message: \(jsonString)")
            
            webSocket?.send(.string(jsonString)) { error in
                if let error = error {
                    print("Failed to send message: \(error)")
                } else {
                    print("Message sent successfully")
                }
            }
        }
    }
    
    private func receiveMessage() {
        webSocket?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received text: \(text)")
                    if let data = text.data(using: .utf8) {
                        self.handleReceivedMessage(data)
                    }
                case .data(let data):
                    self.handleReceivedMessage(data)
                @unknown default:
                    break
                }
                // Continue receiving messages
                self.receiveMessage()
                
            case .failure(let error):
                print("WebSocket receive error: \(error)")
            }
        }
    }
    
    private func handleReceivedMessage(_ data: Data) {
        do {
            let message = try JSONDecoder().decode(Message.self, from: data)
            DispatchQueue.main.async {
                if !self.messages.contains(where: { $0.id == message.id }) {
                    self.messages.append(message)
                    print("Message added: \(message.content) from \(message.username)")
                }
            }
        } catch {
            print("Failed to decode message: \(error)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON: \(jsonString)")
            }
        }
    }
    
    func disconnect() {
        webSocket?.cancel(with: .goingAway, reason: nil)
    }
}
