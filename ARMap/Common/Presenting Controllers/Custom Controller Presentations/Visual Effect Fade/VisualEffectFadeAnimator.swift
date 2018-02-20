//
//  VisualEffectFadeAnimator.swift
//  ARMap
//
//  Created by Kelvin Kosbab on 2/19/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

class VisualEffectFadeAnimator : NSObject, PresentableAnimator {
  
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
    
    if isPresenting {
      
      // Currently presenting
      self.presentingViewControllerDelegate?.willPresentViewController(presentedViewController)
      presentedViewController.view.backgroundColor = .clear
      presentedViewController.view.alpha = 0
      containerView.addSubview(presentedViewController.view)
      UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
        presentedViewController.view.alpha = 1
        presentingViewController.setNeedsStatusBarAppearanceUpdate()
        presentedViewController.setNeedsStatusBarAppearanceUpdate()
        self.presentingViewControllerDelegate?.isPresentingViewController(presentedViewController)
      }, completion: { _ in
        self.presentingViewControllerDelegate?.didPresentViewController(presentedViewController)
        transitionContext.completeTransition(true)
      })
      
    } else {
      
      // Currently not presenting
      self.presentingViewControllerDelegate?.willDismissViewController(presentedViewController)
      UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
        presentedViewController.view.alpha = 0
        presentingViewController.setNeedsStatusBarAppearanceUpdate()
        presentedViewController.setNeedsStatusBarAppearanceUpdate()
        self.presentingViewControllerDelegate?.isDismissingViewController(presentedViewController)
      }, completion: { _ in
        if !transitionContext.transitionWasCancelled {
          self.presentingViewControllerDelegate?.didDismissViewController(presentedViewController)
        }
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
      })
    }
  }
}
