//
//  CollectionView.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 18.08.2025.
//

import UIKit

enum CollectionView {
    enum Cells {
        static let movieHeader = "MovieHeaderCollectionViewCell"
        static let movieHeaderNib = "MovieHeaderCollectionViewCell"
        static let movieListCell = "MovieListTableViewCell"
        static let movieListNib = "MovieListTableViewCell"
        
        static let movieCell = "MovieCell"
        static let heroCell = "HeroCell"
        static let personCell = "PersonCell"
        static let sectionHeader = "SectionHeaderView"
        
        static let casItemCell = "CastItemCollectionViewCell"
        static let castSectionCell = "CastSectionCollectionViewCell"
        
        static let financialCell = "FinancialSummaryCollectionViewCell"
        
        static let genreSectionCell = "GenreCollectionViewCell"
        static let genreItemCell = "GenreSectionCollectionViewCell"
        
        static let movieHeaderCell = "MovieHeaderCollectionViewCell"
        
        static let overviewCell = "OverviewCollectionViewCell"
        
        static let productionCell =  "ProductionCompanyCell"
        
        static let recommendationCell = "RecommendationSectionCollectionViewCell"
    }
    
    static let defaultMinimumLineSpacing: CGFloat = 16
    static let verticalScrollDirection: UICollectionView.ScrollDirection = .vertical
}
