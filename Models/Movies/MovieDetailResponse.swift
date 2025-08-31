//
//  MovieDetailModel.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 28.07.2025.
//

// MARK: - Movie Detail Response
struct MovieDetailResponse: Decodable {
    let id: Int
    let title: String
    let originalTitle: String?
    let originalLanguage: String?
    let overview: String?
    let releaseDate: String?
    let budget: Int?
    let revenue: Int?
    let runtime: Int?
    let homepage: String?
    let genres: [Genre]?
    let productionCompanies: [ProductionCompany]?
    let posterPath: String?
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case originalTitle = "original_title"
        case originalLanguage = "original_language"
        case overview
        case releaseDate = "release_date"
        case budget
        case revenue
        case runtime
        case homepage
        case genres
        case productionCompanies = "production_companies"
        case posterPath = "poster_path"
    }
}
