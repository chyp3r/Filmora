//
//  Colorswift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 18.08.2025.
//

import UIKit

enum ColorConstants {
    static var primaryColor: UIColor { .movieDarkPurple }
    static var secondaryColor: UIColor { .moviePink }
    
    static var labelColor: UIColor { dynamic(light: .label, dark: .label) }
    static var whiteLabelColor: UIColor { dynamic(light: .white, dark: .white) }
    static var profileBorder: UIColor { dynamic(light: .white, dark: .white) }
    static var emptyActionButtonColor: UIColor {.systemPink}
    
    static var secondaryLabelColor: UIColor { dynamic(light: .darkGray, dark: .lightGray) }
    
    static var userBubbleBackground: UIColor { dynamic(light: UIColor.moviePink.withAlphaComponent(0.9),
                                                        dark: UIColor.moviePink.withAlphaComponent(0.9)) }
    
    static var otherBubbleBackground: UIColor { dynamic(light: UIColor(white: 0.9, alpha: 1),
                                                        dark: UIColor(white: 0.18, alpha: 1)) }
    
    static var inputTextFieldBackground: UIColor { dynamic(light: .white, dark: UIColor(white: 0.15, alpha: 1)) }
    
    static var inputPlaceholderColor: UIColor { dynamic(light: .darkGray, dark: .lightGray) }
    
    static var detailPageBoxColor: UIColor { dynamic(light: .white, dark: .systemGray5) }

    private static func dynamic(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? dark : light
            }
        } else {
            return light
        }
    }
}
