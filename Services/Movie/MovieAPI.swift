//
//  MovieAPI.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 28.07.2025.
//

import Moya
import Foundation

// MARK: - Movie API Endpoints
enum MovieAPI {
    case getPopularMovies(page: Int)
    case searchMovies(query: String, page: Int)
    case getMovieDetails(movieId: Int)
    case getMovieCredits(movieId: Int)
    case getMovieRecommendations(movieId: Int)
    case getPersonDetails(personId: Int)
    case getTrendingMovies(page: Int)
    case getTopRatedMovies(page: Int)
    case getPopularPersons(page: Int)
    case getNowPlayingMovies(page: Int)
    case getUpcomingMovies(page: Int)
    case getMovieTranslations(movieId: Int)
}

// MARK: - TargetType
extension MovieAPI: TargetType {
    
    var baseURL: URL {
        guard let url = URL(string: "https://api.themoviedb.org/3") else {
            fatalError("Invalid base URL")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .getPopularMovies: return "/movie/popular"
        case .getTrendingMovies: return "/trending/movie/day"
        case .getTopRatedMovies: return "/movie/top_rated"
        case .getNowPlayingMovies: return "/movie/now_playing"
        case .getUpcomingMovies: return "/movie/upcoming"
        case .searchMovies: return "/search/movie"
        case .getMovieDetails(let id): return "/movie/\(id)"
        case .getMovieCredits(let id): return "/movie/\(id)/credits"
        case .getMovieRecommendations(let id): return "/movie/\(id)/recommendations"
        case .getPersonDetails(let id): return "/person/\(id)"
        case .getPopularPersons: return "/person/popular"
        case .getMovieTranslations(let id): return "/movie/\(id)/translations"
        }
    }
    
    var method: Moya.Method { .get }
    var sampleData: Data { Data() }
    
    var task: Task {
        switch self {
        case .getPopularMovies(let page),
             .getTrendingMovies(let page),
             .getTopRatedMovies(let page),
             .getPopularPersons(let page),
             .getNowPlayingMovies(let page),
             .getUpcomingMovies(let page):
            return .requestParameters(
                parameters: ["page": page, "language": languageCode],
                encoding: URLEncoding.default
            )
            
        case .searchMovies(let query, let page):
            return .requestParameters(
                parameters: ["query": query, "page": page, "language": languageCode],
                encoding: URLEncoding.default
            )
            
        case .getMovieDetails, .getMovieCredits, .getMovieRecommendations, .getPersonDetails:
            return .requestParameters(
                parameters: ["language": languageCode],
                encoding: URLEncoding.default
            )
            
        case .getMovieTranslations:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        [
            "Authorization": "Bearer \(AppConfig.accessToken)",
            "Accept": "application/json"
        ]
    }
}

// MARK: - Helpers
extension MovieAPI {
    var languageCode: String {
        Locale.current.identifier.replacingOccurrences(of: "_", with: "-")
    }
}
