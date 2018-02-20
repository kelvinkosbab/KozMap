//
//  VisualEffectFadePresentationManager.swift
//  ARMap
//
//  Created by Kelvin Kosbab on 2/17/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

class VisualEffectFadePresentationManager : NSObject, PresentableManager {
  
  // MARK: - PresentableManager
  
  var presentationController: UIPresentationController?
  
  var presentationInteractiveTransition: InteractiveTransition?
  var dismissInteractiveTransition: InteractiveTransition?
  
  weak var presentingViewControllerDelegate: PresentingViewControllerDelegate?
  weak var presentedViewControllerDelegate: PresentedViewControllerDelegate?
  
  // MARK: - UIViewControllerTransitioningDelegate
  
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    let presentationController = VisualEffectFadePresentationController(presentedViewController: presented, presenting: source)
    self.presentationController = presentationController
    return presentationController
  }
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    let animator = VisualEffectFadeAnimator()
    animator.presentingViewControllerDelegate = self.presentingViewControllerDelegate
    animator.presentedViewControllerDelegate = self.presentedViewControllerDelegate
    return animator
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    let animator = VisualEffectFadeAnimator()
    animator.presentingViewControllerDelegate = self.presentingViewControllerDelegate
    animator.presentedViewControllerDelegate = self.presentedViewControllerDelegate
    return animator
  }
  
  func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return nil
  }
  
  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return nil
  }
}
