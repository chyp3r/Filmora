//
//  MovieDetailViewModel.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 29.07.2025.
//

import Foundation

final class MovieDetailViewModel {
    let movie: Movie
    private let service = MovieService.shared

    private(set) var movieDetail: MovieDetailResponse?
    private(set) var credits: CreditsResponse?
    private(set) var recommendations: RecommendationsResponse?

    var onDataUpdated: (() -> Void)?
    var onError: ((Error) -> Void)?

    var onBackRequested: (() -> Void)?
    var onHeartStateChanged: ((Bool) -> Void)?
    var onExpandedRequested: ((MovieDetailResponse, [Cast], [Movie]) -> Void)?

    var isHeartFilled: Bool

    init(movie: Movie) {
        self.movie = movie
        self.isHeartFilled = FavoritesManager.shared.isFavorite(movieId: movie.id)
    }

    func fetchMovieDetails() {
        let group = DispatchGroup()

        var fetchError: Error?

        group.enter()
        service.fetchMovieDetail(id: movie.id) { [weak self] result in
            defer { group.leave() }
            switch result {
            case .success(let detail):
                self?.movieDetail = detail
            case .failure(let error):
                fetchError = error
            }
        }

        group.enter()
        service.fetchMovieCredits(id: movie.id) { [weak self] result in
            defer { group.leave() }
            switch result {
            case .success(let credits):
                self?.credits = credits
            case .failure(let error):
                fetchError = error
            }
        }

        group.enter()
        service.fetchMovieRecommendations(id: movie.id) { [weak self] result in
            defer { group.leave() }
            switch result {
            case .success(let recs):
                self?.recommendations = recs
            case .failure(let error):
                fetchError = error
            }
        }

        group.notify(queue: .main) { [weak self] in
            if let error = fetchError {
                self?.onError?(error)
            } else {
                self?.onDataUpdated?()
            }
        }
    }

    func backTapped() {
        onBackRequested?()
    }

    func heartTapped() {
        isHeartFilled.toggle()

        if isHeartFilled {
            FavoritesManager.shared.addFavorite(movie: movie)
        } else {
            FavoritesManager.shared.removeFavorite(movieId: movie.id)
        }

        NotificationCenter.default.post(name: .favoritesChanged, object: nil, userInfo: ["movieId": movie.id])
        onHeartStateChanged?(isHeartFilled)
    }

    func userPulledUp() {
        guard let detail = movieDetail else { return }
        let castList = credits?.cast ?? []
        let recs = recommendations?.results ?? []
        onExpandedRequested?(detail, castList, recs)
    }
}

extension Notification.Name {
    static let favoritesChanged = Notification.Name("favoritesChanged")
}
