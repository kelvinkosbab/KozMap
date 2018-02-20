//
//  BottomUpPresentationManager.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 12/31/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit

class BottomUpPresentationManager : NSObject, PresentableManager {
  
  // MARK: - PresentableManager
  
  var presentationController: UIPresentationController?
  
  var presentationInteractiveTransition: InteractiveTransition?
  var dismissInteractiveTransition: InteractiveTransition?
  
  weak var presentingViewControllerDelegate: PresentingViewControllerDelegate?
  weak var presentedViewControllerDelegate: PresentedViewControllerDelegate?
  
  // MARK: - UIViewControllerTransitioningDelegate
  
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    let presentationController = BottomUpPresentationController(presentedViewController: presented, presenting: source)
    self.presentationController = presentationController
    self.presentationInteractiveTransition = DragDownDismissInteractiveTransition(interactiveViews: self.presentationInteractiveViews, delegate: self)
    self.dismissInteractiveTransition = DragDownDismissInteractiveTransition(interactiveViews: self.dismissInteractiveViews, contentSize: presentedViewController?.preferredContentSize, delegate: self)
    return presentationController
  }
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    let animator = BottomUpAnimator()
    animator.presentingViewControllerDelegate = self.presentingViewControllerDelegate
    animator.presentedViewControllerDelegate = self.presentedViewControllerDelegate
    return animator
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    let animator = BottomUpAnimator()
    animator.presentingViewControllerDelegate = self.presentingViewControllerDelegate
    animator.presentedViewControllerDelegate = self.presentedViewControllerDelegate
    return animator
  }
  
  func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    if let presentationInteractiveTransition = self.presentationInteractiveTransition, presentationInteractiveTransition.hasStarted {
      return presentationInteractiveTransition
    }
    return nil
  }
  
  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    if let dismissInteractiveTransition = self.dismissInteractiveTransition, dismissInteractiveTransition.hasStarted {
      return dismissInteractiveTransition
    }
    return nil
  }
}

// MARK: - InteractiveTransitionDelegate

extension BottomUpPresentationManager : InteractiveTransitionDelegate {
  
  func interactionDidSurpassThreshold(_ interactiveTransition: InteractiveTransition) {
    
    // Presentation
    if interactiveTransition == self.presentationInteractiveTransition {}
    
    // Dismissal
    if interactiveTransition == self.dismissInteractiveTransition {
      self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
  }
}
