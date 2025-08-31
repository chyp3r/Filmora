//
//  MovieModel.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 28.07.2025.
//

// MARK: - Movie Model
struct Movie: Codable, Hashable {
    
    // MARK: - Properties
    let id: Int
    var title: String
    var posterPath: String?
    let releaseDate: String?
    let voteAverage: Double?
    let backdropPath: String?
    let overview: String?
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case backdropPath = "backdrop_path"
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - Equatable
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
    }
}
