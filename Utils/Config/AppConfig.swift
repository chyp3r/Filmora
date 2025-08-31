//
//  AppConfig.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 28.07.2025.
//

import Foundation

struct AppConfig {
    static var apiKey: String {
        return value(for: ConfigKeys.tmdbAPI)
    }
    static var accessToken: String {
        return value(for: ConfigKeys.tmdbToken)
    }
    
    static var geminiApiKey: String {
        return value(for:ConfigKeys.geminiAPI)
    }
    
    private static func value(for key: String) -> String {
        return Bundle.main.object(forInfoDictionaryKey: key) as? String ?? ""
    }
}

