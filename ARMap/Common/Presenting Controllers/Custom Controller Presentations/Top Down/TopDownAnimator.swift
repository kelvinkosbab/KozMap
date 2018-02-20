//
//  TopDownAnimator.swift
//  ARMap
//
//  Created by Kelvin Kosbab on 2/19/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

class TopDownAnimator : NSObject, PresentableAnimator {
  
  // MARK: - PresentableAnimator
  
  weak var presentingViewControllerDelegate: PresentingViewControllerDelegate?
  weak var presentedViewControllerDelegate: PresentedViewControllerDelegate?
  
  // MARK: - UIViewControllerAnimatedTransitioning
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.3
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
    guard let toViewController = transitionContext.viewController(forKey: .to), let fromViewController = transitionContext.viewController(forKey: .from) else {
      return
    }
    
    let isPresenting = toViewController.presentedViewController != fromViewController
    _ = isPresenting ? fromViewController : toViewController
    let presentedViewController = isPresenting ? toViewController : fromViewController
    let containerView = transitionContext.containerView
    
    // Calculate preferred height
    let presentedYOffset: CGFloat = presentedViewController.preferredContentSize.height > 0 ? presentedViewController.preferredContentSize.height : containerView.bounds.height
    
    if isPresenting {
      
      // Currently presenting
      presentedViewController.view.frame.origin.y -= presentedYOffset
      containerView.addSubview(presentedViewController.view)
      UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
        presentedViewController.view.frame.origin.y += presentedYOffset
      }, completion: { _ in
        transitionContext.completeTransition(true)
      })
      
    } else {
      
      // Currently not presenting
      UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
        presentedViewController.view.frame.origin.y -= presentedYOffset
      }, completion: { _ in
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
      })
    }
  }
}
