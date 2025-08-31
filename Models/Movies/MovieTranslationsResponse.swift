//
//  MovieTranslationsResponse.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 12.08.2025.
//

// MARK: - Movie Translations Response
struct MovieTranslationsResponse: Decodable {
    
    let id: Int
    let translations: [Translation]
    
    // MARK: - Translation
    struct Translation: Decodable {
        let iso_639_1: String
        let name: String
        let englishName: String
        let data: TranslationData
        
        enum CodingKeys: String, CodingKey {
            case iso_639_1
            case name
            case englishName = "english_name"
            case data
        }
        
        // MARK: - Translation Data
        struct TranslationData: Decodable {
            let title: String?
            let overview: String?
        }
    }
}
