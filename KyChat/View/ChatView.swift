//
//  ChatView.swift
//  KyChat
//
//  Created by Rizky Azmi Swandy on 11/12/24.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var wsManager: WebSocketManager
    @State private var messageText = ""
    @FocusState private var isFocused: Bool  // Add this to control keyboard focus
    let token: String
    
    init(token: String, username: String, userId: String) {
        self.token = token
        _wsManager = StateObject(wrappedValue: WebSocketManager(
            userId: userId,
            username: username
        ))
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(wsManager.messages) { message in
                            MessageBubble(
                                message: message,
                                isCurrentUser: message.senderId == wsManager.userId
                            )
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: wsManager.messages.count) { _ in
                    if let lastMessage = wsManager.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            HStack {
                TextField("Message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isFocused)  // Bind the focus state
                    .onSubmit {
                        sendMessage()
                    }
                
                Button(action: sendMessage) {
                    Text("Send")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .onTapGesture {
            isFocused = false  // Dismiss keyboard when tapping outside
        }
        .onAppear {
            wsManager.connect(token: token)
        }
        .onDisappear {
            wsManager.disconnect()
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        wsManager.send(content: messageText)
        messageText = ""
    }
}

struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading) {
            // Username from message
            Text(message.username)
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal, 16)
            
            HStack {
                if isCurrentUser {
                    Spacer()
                }
                
                VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                    Text(message.content)
                        .padding(10)
                        .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(isCurrentUser ? .white : .primary)
                        .cornerRadius(16)
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                if !isCurrentUser {
                    Spacer()
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
