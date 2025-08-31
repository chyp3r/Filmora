//
//  String.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 14.08.2025.
//

import UIKit

extension String {
    var initials: String {
        let parts = self.components(separatedBy: " ")
        let initials = parts.compactMap { $0.first }.map { String($0) }
        if initials.count >= 2 {
            return initials[0] + initials[1]
        } else if let first = initials.first {
            return first
        }
        return ""
    }
    
    func coloredSeparators(for trait: UITraitCollection) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: self)
        let separators = self.enumerated().compactMap { index, char -> NSRange? in
            char == "|" ? NSRange(location: index, length: 1) : nil
        }
        let color: UIColor = trait.userInterfaceStyle == .dark ? .lightGray : .black
        separators.forEach { range in
            attributed.addAttribute(.foregroundColor, value: color, range: range)
        }
        return attributed
    }
}
