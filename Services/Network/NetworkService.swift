//
//  NetworkService.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 18.08.2025.
//

import Foundation
import Moya

// MARK: - Network Service
final class NetworkService<Target: TargetType> {
    
    // MARK: - Properties
    private let provider: MoyaProvider<Target>
    
    // MARK: - Init
    init(stub: Bool = false,
         plugins: [PluginType] = []) {
        if stub {
            self.provider = MoyaProvider<Target>(stubClosure: MoyaProvider.immediatelyStub,
                                                 plugins: plugins)
        } else {
            self.provider = MoyaProvider<Target>(plugins: plugins)
        }
    }
    
    // MARK: - Request Handler
    func request<Response: Decodable>(_ target: Target,
                                      completion: @escaping (Result<Response, Error>) -> Void) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                guard (200...299).contains(response.statusCode) else {
                    completion(.failure(NSError(
                        domain: "NetworkService",
                        code: response.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "HTTP Error: \(response.statusCode)"]
                    )))
                    return
                }
                do {
                    let decoded = try JSONDecoder().decode(Response.self, from: response.data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
