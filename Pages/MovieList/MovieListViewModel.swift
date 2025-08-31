//
//  MovieListViewModel.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 28.07.2025.
//

import Foundation

class MovieListViewModel {
    private var currentPage = 1
    private var totalPages = 1
    private(set) var movies: [Movie] = []

    var onMoviesUpdated: (() -> Void)?
    var onError: ((Error) -> Void)?

    private var isLoading = false

    func fetchMovies() {
        guard !isLoading, currentPage <= totalPages else { return }
        isLoading = true

        MovieService.shared.fetchPopularMovies(page: currentPage) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let response):
                    self.movies.append(contentsOf: response.results)
                    self.currentPage += 1
                    self.totalPages = response.totalPages
                    self.onMoviesUpdated?()
                case .failure(let error):
                    if self.movies.isEmpty{
                        self.onError?(error)
                    }
                }
            }
        }
    }

    func reset() {
        currentPage = 1
        totalPages = 1
        movies.removeAll()
    }
}
