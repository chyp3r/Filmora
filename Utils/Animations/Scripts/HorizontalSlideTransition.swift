//
//  SlideTransition.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 28.07.2025.
//

import UIKit

class HorizontalSlideTransition: NSObject, UIViewControllerAnimatedTransitioning {

    let isForward: Bool

    init(isForward: Bool) {
        self.isForward = isForward
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return AnimationConstants.shortFadeDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView
        let width = container.frame.width

        toView.transform = CGAffineTransform(translationX: isForward ? width : -width, y: 0)
        container.addSubview(toView)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromView.transform = CGAffineTransform(translationX: self.isForward ? -width : width, y: 0)
            toView.transform = .identity
        }, completion: { finished in
            fromView.transform = .identity
            transitionContext.completeTransition(finished)
        })
    }
}
