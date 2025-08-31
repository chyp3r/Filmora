//
//  UIImage.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 14.08.2025.
//

import UIKit

extension UIImage {
    static func placeholderImage(symbolName: String? = nil,
                                 size: CGSize = CGSize(width: 120, height: 180),
                                 backgroundColor: UIColor = UIColor.gray.withAlphaComponent(0.3),
                                 symbolTintColor: UIColor = UIColor.gray.withAlphaComponent(0.6)) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        return renderer.image { context in
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            
            if let symbolName = symbolName,
               let symbolImage = UIImage(systemName: symbolName) {
                let symbolConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .regular)
                let symbol = symbolImage.withConfiguration(symbolConfig)
                    .withTintColor(symbolTintColor, renderingMode: .alwaysOriginal)
                
                let symbolSize = symbol.size
                let symbolOrigin = CGPoint(
                    x: (size.width - symbolSize.width) / 2,
                    y: (size.height - symbolSize.height) / 2
                )
                symbol.draw(in: CGRect(origin: symbolOrigin, size: symbolSize))
            }
        }
    }
}
