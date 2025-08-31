//
//  ChatService.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 6.08.2025.
//

import Foundation

final class GeminiChatService: ChatServiceProtocol {
    
    private let apiKey = AppConfig.geminiApiKey
    private let endpoint = GeminiConstants.endPoint
    private let maxMessageHistory = GeminiConstants.maxHistory
    
    func sendMessage(messages: [Message], completion: @escaping (Result<Message, Error>) -> Void) {
        
        guard let url = buildURL() else {
            completion(.failure(ChatServiceError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let systemInstruction = GeminiConstants.systemInstruction
        let limitedMessages = Array(messages.suffix(maxMessageHistory))
        let contents = buildContents(from: limitedMessages)
        
        let jsonBody: [String: Any] = [
            "system_instruction": ["parts": [["text": systemInstruction]]],
            "contents": contents
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(ChatServiceError.noData))
                return
            }
            
            switch self.parseResponse(data: data) {
            case .success(let text):
                let message = Message(text: text, isUser: false)
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Helpers
    private func buildURL() -> URL? {
        guard var components = URLComponents(string: endpoint) else { return nil }
        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]
        return components.url
    }
    
    private func buildContents(from messages: [Message]) -> [[String: Any]] {
        messages.map { message in
            let role = message.isUser ? "user" : "assistant"
            return [
                "role": role,
                "parts": [["text": message.text]]
            ]
        }
    }
    
    private func parseResponse(data: Data) -> Result<String, Error> {
        do {
            guard
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                let candidates = json["candidates"] as? [[String: Any]],
                let firstCandidate = candidates.first,
                let content = firstCandidate["content"] as? [String: Any],
                let parts = content["parts"] as? [[String: Any]],
                let firstPart = parts.first,
                let text = firstPart["text"] as? String
            else {
                return .failure(ChatServiceError.invalidResponse)
            }
            
            return .success(text.trimmingCharacters(in: .whitespacesAndNewlines))
        } catch {
            return .failure(error)
        }
    }
}
