//
//  SkeletonImageView.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 7.08.2025.
//

import UIKit
import Kingfisher

final class SkeletonImageLoader {
    private static var shimmerAnimationKey = "shimmerAnimationKey"
    private static var shimmerAnimationKeyPointer: UnsafeRawPointer {
        return UnsafeRawPointer(bitPattern: ObjectIdentifier(shimmerAnimationKey as AnyObject).hashValue)!
    }
    
    private static var loadingImageViews = NSHashTable<UIImageView>.weakObjects()
    private static var pendingImages = NSMapTable<UIImageView, UIImage>.weakToStrongObjects()
    
    @MainActor
    static func loadImage(
        into imageView: UIImageView,
        from path: String?,
        baseUrl: String,
        placeholder: UIImage?,
        skeletonBaseColor: UIColor,
        fadeDuration: TimeInterval = AnimationConstants.shortFadeDuration,
        cornerRadius: CGFloat = 0
    ) {
        imageView.layer.cornerRadius = cornerRadius
        imageView.clipsToBounds = cornerRadius > 0
        imageView.image = placeholder
        
        guard let path = path, let url = URL(string: baseUrl + path) else { return }
        
        loadingImageViews.add(imageView)
        
        Task {
            let cacheKey = url.absoluteString

            if let cachedImage = ImageCache.default.retrieveImageInMemoryCache(forKey: cacheKey) {
                await MainActor.run {
                    imageView.image = cachedImage
                }
                return
            }

            ImageCache.default.retrieveImage(forKey: cacheKey, options: nil) { result in
                switch result {
                case .success(let value):
                    if let diskCachedImage = value.image {
                        Task { @MainActor in
                            imageView.image = diskCachedImage
                        }
                        return
                    } else {
                        Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 300_000_000)
                            if loadingImageViews.contains(imageView), imageView.image == nil {
                                startShimmeringAnimation(
                                    on: imageView,
                                    baseColor: skeletonBaseColor.withAlphaComponent(0.05),
                                    cornerRadius: cornerRadius
                                )
                            }
                        }
                    }
                case .failure(_):
                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: 300_000_000)
                        if loadingImageViews.contains(imageView), imageView.image == nil {
                            startShimmeringAnimation(
                                on: imageView,
                                baseColor: skeletonBaseColor.withAlphaComponent(0.05),
                                cornerRadius: cornerRadius
                            )
                        }
                    }
                }
            }
        }

        let options: KingfisherOptionsInfo = [
            .transition(.fade(fadeDuration)),
            .forceTransition,
            .loadDiskFileSynchronously,
            .processor(RoundCornerImageProcessor(cornerRadius: cornerRadius))
        ]
        
        imageView.kf.setImage(
            with: url,
            placeholder: nil,
            options: options
        ) { result in
            loadingImageViews.remove(imageView)
            
            if case .failure(_) = result {
                imageView.image = placeholder
                stopShimmeringAnimation(on: imageView, fadeDuration: 0)
            } else {
                pendingStopViews.insert(imageView)
            }
        }
    }
    
    private static var pendingStopViews = Set<UIView>()
    
    private class AnimationDelegate: NSObject, CAAnimationDelegate {
        weak var view: UIView?
        var fadeDuration: TimeInterval
        
        init(view: UIView, fadeDuration: TimeInterval) {
            self.view = view
            self.fadeDuration = fadeDuration
        }
        
        func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
            guard let view = view else { return }
            if pendingStopViews.contains(view) {
                pendingStopViews.remove(view)
                stopShimmeringAnimation(on: view, fadeDuration: fadeDuration)
            }
        }
    }
    
    private static func startShimmeringAnimation(
        on view: UIView,
        baseColor: UIColor,
        cornerRadius: CGFloat
    ) {
        view.layer.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach { $0.removeFromSuperlayer() }

        let gradientLayer = CAGradientLayer()
        gradientLayer.cornerRadius = cornerRadius
        gradientLayer.frame = view.bounds
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)

        let darkColor = baseColor.darker(by: 20).cgColor
        let lightColor = baseColor.lighter(by: 20).cgColor
        gradientLayer.colors = [darkColor, lightColor, darkColor]
        gradientLayer.locations = [0.0, 0.5, 1.0]

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-0.3, 0.0, 0.3]
        animation.toValue = [0.7, 1.0, 1.3]
        animation.duration = 1.6
        animation.repeatCount = 1
        animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)

        let delegate = CycleAnimationDelegate(view: view, baseColor: baseColor, cornerRadius: cornerRadius)
        animation.delegate = delegate
        objc_setAssociatedObject(view, shimmerAnimationKeyPointer, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        gradientLayer.add(animation, forKey: shimmerAnimationKey)
        view.layer.addSublayer(gradientLayer)
    }

    
    private class CycleAnimationDelegate: NSObject, CAAnimationDelegate {
        weak var view: UIView?
        var baseColor: UIColor
        var cornerRadius: CGFloat
        
        init(view: UIView, baseColor: UIColor, cornerRadius: CGFloat) {
            self.view = view
            self.baseColor = baseColor
            self.cornerRadius = cornerRadius
        }
        
        func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
            guard let view = view else { return }
            
            if SkeletonImageLoader.pendingStopViews.contains(view){
                SkeletonImageLoader.pendingStopViews.remove(view)
                SkeletonImageLoader.stopShimmeringAnimation(on: view, fadeDuration: 0)
            } else {
                SkeletonImageLoader.startShimmeringAnimation(
                    on: view,
                    baseColor: baseColor,
                    cornerRadius: cornerRadius
                )
            }
        }
    }
    
    
    private static func stopShimmeringAnimation(on view: UIView, fadeDuration: TimeInterval) {
        if let gradientLayer = view.layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
            CATransaction.begin()
            CATransaction.setCompletionBlock { gradientLayer.removeFromSuperlayer() }
            
            let fadeOut = CABasicAnimation(keyPath: "opacity")
            fadeOut.fromValue = 1.0
            fadeOut.toValue = 0.0
            fadeOut.duration = fadeDuration
            fadeOut.fillMode = .forwards
            fadeOut.isRemovedOnCompletion = false
            
            gradientLayer.add(fadeOut, forKey: "fadeOutAnimation")
            CATransaction.commit()
        }
    }
}
