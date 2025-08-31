//
//  ExpandedMovieDetailViewswift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 18.08.2025.
//

enum ExpandedMovieDetailViewConstants{
    enum Section: Int {
        case header = 0
        case genres
        case overview
        case financialSummary
        case cast
        case recommendations
        
        static var count: Int { return 6 }
    }
    static let minimumLineSpacing = 16.0
}
