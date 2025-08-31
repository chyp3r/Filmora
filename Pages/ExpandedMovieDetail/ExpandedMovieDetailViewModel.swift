//
//  ExpandedMovieDetailViewModel.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 30.07.2025.
//

import Foundation

final class ExpandedMovieDetailViewModel {
    private let movieDetail: MovieDetailResponse
    let cast: [Cast]
    let recommendations: [Movie]
    
    // MARK: - Init
    init(movieDetail: MovieDetailResponse, cast: [Cast], recommendations: [Movie]) {
        self.movieDetail = movieDetail
        self.cast = Array(Set(cast))
        self.recommendations = Array(Set(recommendations))
    }
    
    // MARK: - Computed Properties
    
    var title: String { movieDetail.title }
    var originalTitle: String { movieDetail.originalTitle ?? ""}
    var originalLanguage: String { movieDetail.originalLanguage?.uppercased() ?? "" }
    
    var budget: Int { movieDetail.budget ?? 0 }
    var revenue: Int { movieDetail.revenue ?? 0}
    
    var overview: String {
        if let overview = movieDetail.overview, !overview.isEmpty {
            return overview
        }
        return TextConstants.noOverview
    }
    
    var productionCompanies: [ProductionCompany] {
        return movieDetail.productionCompanies ?? []
    }
    
    var genres: [String] {
        guard let genres = movieDetail.genres, !genres.isEmpty else {
            return []
        }
        return genres.map { $0.name }
    }
    
    // MARK: - Callbacks
    
    var onBackRequested: (() -> Void)?
    var onDataUpdated: (() -> Void)?
    var onError: ((Error) -> Void)?

    var didSelectCast: ((Cast) -> Void)?
    var didSelectRecommendation: ((Movie) -> Void)?
    
    // MARK: - Actions
    
    func backTapped() {
        onBackRequested?()
    }
    
    func reloadData() {
        onDataUpdated?()
    }
}

