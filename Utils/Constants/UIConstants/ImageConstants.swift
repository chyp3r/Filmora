//
//  Imageswift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 18.08.2025.
//

import UIKit

enum ImageConstants {
    static let baseOriginal = "https://image.tmdb.org/t/p/original"
    static let baseW92 = "https://image.tmdb.org/t/p/w92"
    static let baseW154 = "https://image.tmdb.org/t/p/w154"
    static let baseW185 = "https://image.tmdb.org/t/p/w185"
    static let baseW200 = "https://image.tmdb.org/t/p/w200"
    static let baseW300 = "https://image.tmdb.org/t/p/w300"
    static let baseW342 = "https://image.tmdb.org/t/p/w342"
    static let baseW500 = "https://image.tmdb.org/t/p/w500"
    static let baseW780 = "https://image.tmdb.org/t/p/w780"
    static let baseW1280 = "https://image.tmdb.org/t/p/w1280"
    static let baseH632 = "https://image.tmdb.org/t/p/h632"
    
    static func url(for path: String?, sizeBase: String = baseW500) -> URL? {
        guard let p = path, !p.isEmpty else { return nil }
        return URL(string: "\(sizeBase)\(p)")
    }
    
    static let placeholderName = "placeholder"
    static var filmPlaceHolder: UIImage {
        UIImage.placeholderImage(symbolName: "film.fill")
    }
    
    static var photoPlaceHolder: UIImage {
        UIImage.placeholderImage(symbolName: "photo.fill")
    }
    
    static var nullPlaceHolder: UIImage {
        UIImage.placeholderImage(symbolName: nil)
    }
    
    static var filmIconImage: UIImage? {
            return UIImage(systemName: "film.fill")?
                .withTintColor(.gray, renderingMode: .alwaysOriginal)
    }
    
    static var deleteIconImage = UIImage(systemName: "xmark.circle.fill")
    
    static var budgetIconImageName = "dollarsign.circle"
    static var revenueIconImageName = "chart.line.uptrend.xyaxis"
}
