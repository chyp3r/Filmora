//
//  Fontswift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 18.08.2025.
//

import UIKit

enum FontConstants {
    static let titleSize: CGFloat = 24
    static let bodySize: CGFloat = 16
    
    static var titleFont: UIFont { UIFont.boldSystemFont(ofSize: titleSize) }
    static var bodyFont: UIFont { UIFont.systemFont(ofSize: bodySize) }
    
    static let navBarTitleFont = UIFont.systemFont(ofSize: titleSize, weight: .bold)
    
    static let searchBarFont = UIFont.systemFont(ofSize: bodySize, weight: .medium)
    
    static let emptyMessageFont = UIFont.systemFont(ofSize: 20, weight: .medium)
    
    static let emptyActionButtonFont = UIFont.systemFont(ofSize: bodySize, weight: .semibold)
    
    static let bigInitialsFont = UIFont.systemFont(ofSize: 64, weight: .bold)
}
