//
//  VisualEffectFadePresentationController.swift
//  ARMap
//
//  Created by Kelvin Kosbab on 2/19/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

class VisualEffectFadePresentationController : UIPresentationController {
  
  // MARK: - Properties
  
  private var blurView: UIVisualEffectView? = nil
  
  override var shouldPresentInFullscreen: Bool {
    return true
  }
  
  // MARK: - Blur View
  
  private func createBlurView() -> UIVisualEffectView {
    let blurView = UIVisualEffectView(effect: nil)
    blurView.frame = self.presentingViewController.view.bounds
    return blurView
  }
  
  // MARK: - UIPresentationController
  
  override func presentationTransitionWillBegin() {
    
    guard let containerView = self.containerView else {
      return
    }
    
    // Setup blur view
    let blurView = self.blurView ?? self.createBlurView()
    self.blurView = blurView
    blurView.addToContainer(containerView, atIndex: 0)
    blurView.effect = nil
    
    // Begin animation
    self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { context in
      blurView.effect = UIBlurEffect(style: .dark)
    }, completion: nil)
  }
  
  override func dismissalTransitionWillBegin() {
    self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { context in
      self.blurView?.effect = nil
    }, completion: nil)
  }
  
  override var frameOfPresentedViewInContainerView: CGRect {
    return self.containerView?.frame ?? UIScreen.main.bounds
  }
  
  // MARK: - Actions
  
  @objc func dismissController() {
    self.presentedViewController.dismiss(animated: true, completion: nil)
  }
}
