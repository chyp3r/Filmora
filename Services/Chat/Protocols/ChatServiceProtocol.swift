//
//  ChatServiceProtocol.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 18.08.2025.
//

protocol ChatServiceProtocol {
    func sendMessage(messages: [Message],
                     completion: @escaping (Result<Message, Error>) -> Void)
}
