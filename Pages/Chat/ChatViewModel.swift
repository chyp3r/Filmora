//
//  ChatViewModel.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 6.08.2025.
//

import Foundation

final class ChatViewModel {
    
    // MARK: - Properties
    private(set) var messages: [Message] = []
    var onMessagesUpdated: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    private let chatService: ChatServiceProtocol
    
    // MARK: - Initialization
    init(chatService: ChatServiceProtocol = GeminiChatService()) {
        self.chatService = chatService
    }
    
    // MARK: - Helpers
    private func getLastMessagesForPrompt(maxCount: Int = 10) -> [Message] {
        Array(messages.suffix(maxCount))
    }
    
    // MARK: - Actions
    func sendMessage(_ text: String) {
        let userMessage = Message(text: text, isUser: true)
        messages.append(userMessage)
        DispatchQueue.main.async {
            self.onMessagesUpdated?()
        }
        
        let promptMessages = getLastMessagesForPrompt()
        
        chatService.sendMessage(messages: promptMessages) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let replyMessage):
                    self.messages.append(replyMessage)
                    self.onMessagesUpdated?()
                case .failure(let error):
                    self.onError?(error)
                }
            }
        }
    }
    
    func numberOfMessages() -> Int {
        messages.count
    }
    
    func message(at index: Int) -> Message {
        messages[index]
    }
}
