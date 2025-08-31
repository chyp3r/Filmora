//
//  CreditsModel.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 28.07.2025.
//

// MARK: - Credits Response
struct CreditsResponse: Decodable {
    
    // MARK: - Properties
    let id: Int
    let cast: [Cast]
}
