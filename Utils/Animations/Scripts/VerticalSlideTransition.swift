//
//  VerticalSlideTransition.swift
//  MovieApp
//
//  Created by gokdeniz.kuruca on 1.08.2025.
//

import UIKit

class VerticalSlideTransition: NSObject, UIViewControllerAnimatedTransitioning {
    enum Mode {
        case push
        case pop
    }
    
    private let mode: Mode
    init(mode: Mode) {
        self.mode = mode
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return AnimationConstants.longFadeDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        
        let finalFrame = transitionContext.finalFrame(for: transitionContext.viewController(forKey: .to)!)
        
        switch mode {
        case .push:
            toView.frame = finalFrame.offsetBy(dx: 0, dy: finalFrame.height)
            container.addSubview(toView)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           delay: 0,
                           options: [.curveEaseInOut],
                           animations: {
                fromView.frame = fromView.frame.offsetBy(dx: 0, dy: -fromView.frame.height)
                toView.frame = finalFrame
            }, completion: { finished in
                transitionContext.completeTransition(finished)
            })
            
        case .pop:
            container.insertSubview(toView, belowSubview: fromView)
            toView.frame = finalFrame.offsetBy(dx: 0, dy: -finalFrame.height)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           delay: 0,
                           options: [.curveEaseInOut],
                           animations: {
                fromView.frame = fromView.frame.offsetBy(dx: 0, dy: fromView.frame.height)
                toView.frame = finalFrame
            }, completion: { finished in
                transitionContext.completeTransition(finished)
            })
        }
    }
}
