//
//  TopKnobBottomUpPresentationManager.swift
//  ARMap
//
//  Created by Kelvin Kosbab on 2/17/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

class TopKnobBottomUpPresentationManager : NSObject, PresentableManager {
  
  // MARK: - PresentableManager
  
  var presentationController: UIPresentationController?
  
  var presentationInteractiveTransition: InteractiveTransition?
  var dismissInteractiveTransition: InteractiveTransition?
  
  weak var presentingViewControllerDelegate: PresentingViewControllerDelegate?
  weak var presentedViewControllerDelegate: PresentedViewControllerDelegate?
  
  // MARK: - UIViewControllerTransitioningDelegate
  
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    let presentationController = TopKnobBottomUpPresentationController(presentedViewController: presented, presenting: source)
    self.presentationController = presentationController
    return presentationController
  }
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    let animator = TopKnobBottomUpAnimator()
    animator.presentingViewControllerDelegate = self.presentingViewControllerDelegate
    animator.presentedViewControllerDelegate = self.presentedViewControllerDelegate
    return animator
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    let animator = TopKnobBottomUpAnimator()
    animator.presentingViewControllerDelegate = self.presentingViewControllerDelegate
    animator.presentedViewControllerDelegate = self.presentedViewControllerDelegate
    return animator
  }
  
  func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    if let presentationInteractiveTransition = self.presentationInteractiveTransition {
      return presentationInteractiveTransition.hasStarted ? presentationInteractiveTransition : nil
    } else if let presentationInteractiveTransition = DragDownDismissInteractiveTransition(interactiveViews: self.presentationInteractiveViews, delegate: self) {
      self.presentationInteractiveTransition = presentationInteractiveTransition
      return presentationInteractiveTransition
    }
    return nil
  }
  
  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    if let dismissInteractiveTransition = self.dismissInteractiveTransition {
      return dismissInteractiveTransition.hasStarted ? dismissInteractiveTransition : nil
    } else if let dismissInteractiveTransition = DragDownDismissInteractiveTransition(interactiveViews: self.dismissInteractiveViews, delegate: self) {
      self.dismissInteractiveTransition = dismissInteractiveTransition
      return dismissInteractiveTransition
    }
    return nil
  }
}

// MARK: - InteractiveTransitionDelegate

extension TopKnobBottomUpPresentationManager : InteractiveTransitionDelegate {
  
  func interactionDidSurpassThreshold(_ interactiveTransition: InteractiveTransition) {
    
    // Presentation
    if interactiveTransition == self.presentationInteractiveTransition {}
    
    // Dismissal
    if interactiveTransition == self.dismissInteractiveTransition {
      self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
  }
}
