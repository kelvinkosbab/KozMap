//
//  LeftMenuPresentationController.swift
//  ARMap
//
//  Created by Kelvin Kosbab on 2/19/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

class LeftMenuPresentationController : CustomPresentationController {
  
  // MARK: - Properties
  
  private var dismissView: UIVisualEffectView? = nil
  
  // MARK: - Fullscreen
  
  override var shouldPresentInFullscreen: Bool {
    return false
  }
  
  // MARK: - UIPresentationController
  
  override func presentationTransitionWillBegin() {
    super.presentationTransitionWillBegin()
    
    guard let containerView = self.containerView else {
      return
    }
    
    // Setup blur view
    let dismissView = UIVisualEffectView(effect: nil)
    dismissView.frame = self.presentingViewController.view.bounds
    self.dismissView = dismissView
    dismissView.addToContainer(containerView, atIndex: 0)
    dismissView.effect = nil
    
    // Begin animation
    self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { context in
      dismissView.effect = UIBlurEffect(style: .dark)
    }, completion: nil)
    
    // Configure presentation interaction
    self.presentationInteractiveTransition = DragLeftDismissInteractiveTransition(interactiveViews: self.presentationInteractiveViews, delegate: self)
  }
  
  override func presentationTransitionDidEnd(_ completed: Bool) {
    super.presentationTransitionDidEnd(completed)
    
    if completed {
      
      // Configure dismiss interaction
      self.dismissInteractiveTransition = DragLeftDismissInteractiveTransition(interactiveViews: self.dismissInteractiveViews, contentSize: presentedViewController.preferredContentSize, delegate: self)
    }
  }
  
  override func dismissalTransitionWillBegin() {
    super.dismissalTransitionWillBegin()
    
    self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { context in
      self.dismissView?.effect = nil
    }, completion: nil)
  }
  
  override var frameOfPresentedViewInContainerView: CGRect {
    let containerBounds = self.containerView?.bounds ?? UIScreen.main.bounds
    return CGRect(x: 0, y: 0, width: 280, height: containerBounds.height)
  }
  
  // MARK: - Actions
  
  @objc func dismissController() {
    self.presentingViewController.dismiss(animated: true, completion: nil)
  }
}

// MARK: - InteractiveTransitionDelegate

extension LeftMenuPresentationController : InteractiveTransitionDelegate {
  
  func interactionDidSurpassThreshold(_ interactiveTransition: InteractiveTransition) {
    
    // Presentation
    if interactiveTransition == self.presentationInteractiveTransition {}
    
    // Dismissal
    if interactiveTransition == self.dismissInteractiveTransition {
      self.dismissController()
    }
  }
}
