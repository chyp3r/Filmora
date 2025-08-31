//
//  Untitled.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 14.08.2025.
//

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
