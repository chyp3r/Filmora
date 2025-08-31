//
//  ProductionCompanyModel.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 1.08.2025.
//

// MARK: - Production Company Model
struct ProductionCompany: Decodable {
    
    // MARK: - Properties
    let id: Int
    let name: String
    let logoPath: String?
    let originCountry: String?
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case logoPath = "logo_path"
        case originCountry = "origin_country"
    }
}
