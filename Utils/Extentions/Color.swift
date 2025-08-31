//
//  Color.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 14.08.2025.
//
import UIKit

extension UIColor {
    func lighter(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjust(by: abs(percentage))
    }
    
    func darker(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjust(by: -abs(percentage))
    }
    
    private func adjust(by percentage: CGFloat) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(
                red: min(r + percentage/100, 1.0),
                green: min(g + percentage/100, 1.0),
                blue: min(b + percentage/100, 1.0),
                alpha: 1.0
            )
        } else {
            return self
        }
    }
}
