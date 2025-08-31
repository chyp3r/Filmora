//
//  MessageModel.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 6.08.2025.
//

import Foundation

// MARK: - Message Model
struct Message: Identifiable {
    let id: UUID
    let text: String
    let isUser: Bool
    
    // MARK: - Initialization
    init(id: UUID = UUID(), text: String, isUser: Bool) {
        self.id = id
        self.text = text
        self.isUser = isUser
    }
}
