//
//  MovieListResponse.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 1.08.2025.
//

// MARK: - Movie List Response
struct MovieListResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalResults: Int
    let totalPages: Int
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalResults = "total_results"
        case totalPages = "total_pages"
    }
}
