//
//  TopKnobBottomUpAnimator.swift
//  ARMap
//
//  Created by Kelvin Kosbab on 2/19/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

class TopKnobBottomUpAnimator : NSObject, PresentableAnimator {
  
  // MARK: - PresentableAnimator
  
  weak var presentingViewControllerDelegate: PresentingViewControllerDelegate?
  weak var presentedViewControllerDelegate: PresentedViewControllerDelegate?
  
  // MARK: - UIViewControllerAnimatedTransitioning
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.3
  }
  
  final func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
    guard let toViewController = transitionContext.viewController(forKey: .to), let fromViewController = transitionContext.viewController(forKey: .from) else {
      return
    }
    
    let isPresenting = toViewController.presentedViewController != fromViewController
    let presentingViewController = isPresenting ? fromViewController : toViewController
    let presentedViewController = isPresenting ? toViewController : fromViewController
    let containerView = transitionContext.containerView
    
    // Preferred height of the presented controller
    let preferredHeight = presentedViewController.preferredContentSize.height
    let knobViewRequiredOffset = TopKnobVisualEffectView.topKnobSpace + TopKnobVisualEffectView.knobHeight + TopKnobVisualEffectView.bottomKnobSpace
    let presentedYOffset: CGFloat = preferredHeight + knobViewRequiredOffset
    
    if isPresenting {
      
      // Currently presenting
      self.presentingViewControllerDelegate?.willPresentViewController(presentedViewController)
      presentedViewController.view.frame.origin.y = containerView.bounds.height
      containerView.addSubview(presentedViewController.view)
      
      // Animate the presentation
      UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
        presentingViewController.setNeedsStatusBarAppearanceUpdate()
        presentedViewController.setNeedsStatusBarAppearanceUpdate()
        presentedViewController.view.frame.origin.y -= presentedYOffset
        self.presentingViewControllerDelegate?.isPresentingViewController(presentedViewController)
      }, completion: { (_) in
        self.presentingViewControllerDelegate?.didPresentViewController(presentedViewController)
        transitionContext.completeTransition(true)
      })
      
    } else {
      
      // Currently dismissing
      self.presentingViewControllerDelegate?.willDismissViewController(presentedViewController)
      UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
        presentingViewController.setNeedsStatusBarAppearanceUpdate()
        presentedViewController.setNeedsStatusBarAppearanceUpdate()
        presentedViewController.view.frame.origin.y += presentedYOffset
        self.presentingViewControllerDelegate?.isDismissingViewController(presentedViewController)
      }, completion: { (_) in
        if !transitionContext.transitionWasCancelled {
          self.presentingViewControllerDelegate?.didDismissViewController(presentedViewController)
        }
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
      })
    }
  }
}
