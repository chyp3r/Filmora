//
//  CastModel.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 1.08.2025.
//

// MARK: - Cast Model
struct Cast: Decodable, Hashable {
    
    // MARK: - Properties
    let id: Int
    let name: String
    let character: String
    let profilePath: String?
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case character
        case profilePath = "profile_path"
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - Equatable
    static func == (lhs: Cast, rhs: Cast) -> Bool {
        return lhs.id == rhs.id
    }
}
