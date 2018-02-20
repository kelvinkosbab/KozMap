//
//  TopKnobBottomUpPresentationController.swift
//  ARMap
//
//  Created by Kelvin Kosbab on 2/19/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

class TopKnobBottomUpPresentationController : UIPresentationController, DismissInteractable {
  
  // MARK: - Properties
  
  private var dismissView: UIView? = nil
  private var topKnobVisualEffectView: TopKnobVisualEffectView? = nil
  
  // MARK: - DismissInteractable
  
  var dismissInteractiveView: UIView? {
    return self.topKnobVisualEffectView
  }
  
  // MARK: - Fullscreen
  
  override var shouldPresentInFullscreen: Bool {
    return false
  }
  
  // MARK: - UIPresentationController
  
  override func presentationTransitionWillBegin() {
    
    guard let containerView = self.containerView else {
      return
    }
    
    // Setup dismiss view
    let dismissView = UIView()
    dismissView.backgroundColor = .clear
    dismissView.frame = self.presentingViewController.view.bounds
    dismissView.isUserInteractionEnabled = true
    dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissController)))
    self.dismissView = dismissView
    dismissView.addToContainer(containerView)
    
    // Configure the top knob view
    if self.topKnobVisualEffectView == nil, let presentedView = self.presentedView {
      
      // Crate the knob view
      let topKnobVisualEffectView = TopKnobVisualEffectView.newView()
      let knobViewRequiredOffset = TopKnobVisualEffectView.topKnobSpace + TopKnobVisualEffectView.knobHeight + TopKnobVisualEffectView.bottomKnobSpace
      topKnobVisualEffectView.addToContainer(presentedView, atIndex: 0, topMargin: -knobViewRequiredOffset)
      
      // Adjust the presented controller preferred content size
      let containerBounds = self.containerView?.bounds ?? UIScreen.main.bounds
      self.presentedViewController.preferredContentSize.height = self.presentedViewController.preferredContentSize.height > 0 ? self.presentedViewController.preferredContentSize.height + knobViewRequiredOffset : containerBounds.height
    }
  }
  
  override func presentationTransitionDidEnd(_ completed: Bool) {
    if !completed {
      self.dismissView?.removeFromSuperview()
      self.dismissView = nil
      self.topKnobVisualEffectView?.removeFromSuperview()
      self.topKnobVisualEffectView = nil
    }
  }
  
  override var frameOfPresentedViewInContainerView: CGRect {
    let containerBounds = self.containerView?.bounds ?? UIScreen.main.bounds
    let height: CGFloat = self.presentedViewController.preferredContentSize.height
    return CGRect(x: 0, y: containerBounds.height - height, width: containerBounds.width, height: height)
  }
  
  // MARK: - Actions
  
  @objc func dismissController() {
    self.presentingViewController.dismiss(animated: true, completion: nil)
  }
}
