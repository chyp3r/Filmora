//
//  PersonDetailModel.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 28.07.2025.
//

// MARK: - Person Detail Model
struct PersonDetail: Codable {
    
    // MARK: - Properties
    let id: Int
    let name: String
    let biography: String?
    let birthday: String?
    let deathday: String?
    let placeOfBirth: String?
    let profilePath: String?
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case biography
        case birthday
        case deathday
        case placeOfBirth = "place_of_birth"
        case profilePath = "profile_path"
    }
}

// MARK: - Person List Response
struct PersonListResponse: Codable {
    
    // MARK: - Properties
    let page: Int
    let results: [PersonDetail]
    let totalPages: Int
    let totalResults: Int
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
