//
//  MovieDetailNavView.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 31.07.2025.
//

import UIKit

final class MovieDetailNavView: UIView {

    private var gradientLayer: CAGradientLayer?

    override func layoutSubviews() {
        super.layoutSubviews()
        setupGradient()
    }

    private func setupGradient() {
        gradientLayer?.removeFromSuperlayer()

        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.black.withAlphaComponent(0.8).cgColor,
            UIColor.clear.withAlphaComponent(0.2).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.frame = bounds

        layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }
}
