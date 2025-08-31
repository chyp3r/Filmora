//
//  MovieService.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 28.07.2025.
//

import Foundation

// MARK: - Movie Service
final class MovieService {
    
    // MARK: - Singleton
    static let shared = MovieService()
    private let network = NetworkService<MovieAPI>()
    private init() {}
    
    // MARK: - Endpoints
    func fetchPopularMovies(page: Int = 1,
                            completion: @escaping (Result<MovieListResponse, Error>) -> Void) {
        network.request(.getPopularMovies(page: page), completion: completion)
    }
    
    func fetchMovieDetail(id: Int,
                          completion: @escaping (Result<MovieDetailResponse, Error>) -> Void) {
        network.request(.getMovieDetails(movieId: id), completion: completion)
    }
    
    func fetchMovieCredits(id: Int,
                           completion: @escaping (Result<CreditsResponse, Error>) -> Void) {
        network.request(.getMovieCredits(movieId: id), completion: completion)
    }
    
    func fetchMovieRecommendations(id: Int,
                                   completion: @escaping (Result<RecommendationsResponse, Error>) -> Void) {
        network.request(.getMovieRecommendations(movieId: id), completion: completion)
    }
    
    func fetchSearchMovies(query: String,
                           page: Int = 1,
                           completion: @escaping (Result<MovieListResponse, Error>) -> Void) {
        network.request(.searchMovies(query: query, page: page), completion: completion)
    }
    
    func fetchPersonDetail(id: Int,
                           completion: @escaping (Result<PersonDetail, Error>) -> Void) {
        network.request(.getPersonDetails(personId: id), completion: completion)
    }
    
    func fetchTrendingMovies(page: Int = 1,
                             completion: @escaping (Result<MovieListResponse, Error>) -> Void) {
        network.request(.getTrendingMovies(page: page), completion: completion)
    }
    
    func fetchTopRatedMovies(page: Int = 1,
                             completion: @escaping (Result<MovieListResponse, Error>) -> Void) {
        network.request(.getTopRatedMovies(page: page), completion: completion)
    }
    
    func fetchNowPlayingMovies(page: Int = 1,
                               completion: @escaping (Result<MovieListResponse, Error>) -> Void) {
        network.request(.getNowPlayingMovies(page: page), completion: completion)
    }
    
    func fetchUpcomingMovies(page: Int = 1,
                             completion: @escaping (Result<MovieListResponse, Error>) -> Void) {
        network.request(.getUpcomingMovies(page: page), completion: completion)
    }
    
    func fetchPopularPersons(page: Int = 1,
                             completion: @escaping (Result<PersonListResponse, Error>) -> Void) {
        network.request(.getPopularPersons(page: page), completion: completion)
    }
    
    func fetchMovieTranslations(id: Int,
                                completion: @escaping (Result<MovieTranslationsResponse, Error>) -> Void) {
        network.request(.getMovieTranslations(movieId: id), completion: completion)
    }
    
    // MARK: - Helper Endpoints
    func fetchFeaturedMovie(completion: @escaping (Result<Movie?, Error>) -> Void) {
        fetchPopularMovies { result in
            switch result {
            case .success(let response):
                completion(.success(response.results.first))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
