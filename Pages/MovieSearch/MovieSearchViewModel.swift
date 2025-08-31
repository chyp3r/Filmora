//
//  MovieSearchViewModel.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 31.07.2025.
//
final class MovieSearchViewModel {
    private var currentPage = 1
    private var isFetching = false
    private var totalPages = 1
    private var currentQuery: String = ""

    private(set) var movies: [Movie] = []
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    var onMovieSelected: ((Movie) -> Void)?

    func searchMovies(query: String) {
        guard !query.isEmpty, !isFetching else { return }
        isFetching = true
        currentPage = 1
        totalPages = 1
        currentQuery = query
        movies.removeAll()
        
        fetchMovies(query: query, page: currentPage)
    }
    
    func loadMore() {
        guard !isFetching, currentPage < totalPages else { return }
        isFetching = true
        currentPage += 1
        
        fetchMovies(query: currentQuery, page: currentPage)
    }
    
    private func fetchMovies(query: String, page: Int) {
        MovieService.shared.fetchSearchMovies(query: query, page: page) { [weak self] result in
            guard let self = self else { return }
            self.isFetching = false
            switch result {
            case .success(let response):
                if page == 1 {
                    self.movies = response.results
                    self.totalPages = response.totalPages
                } else {
                    self.movies.append(contentsOf: response.results)
                }
                self.onUpdate?()
            case .failure(let error):
                self.onError?(error)
                print(error)
            }
        }
    }
}
