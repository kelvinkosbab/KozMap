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
    return true
  }
  
  // MARK: - Blur View
  
  private func createDismissView() -> UIView {
    let view = UIView()
    view.backgroundColor = .clear
    view.frame = self.presentingViewController.view.bounds
    view.isUserInteractionEnabled = true
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissController)))
    return view
  }
  
  // MARK: - UIPresentationController
  
  override func presentationTransitionWillBegin() {
    
    guard let containerView = self.containerView else {
      return
    }
    
    // Setup blur view
    let dismissView = self.dismissView ?? self.createDismissView()
    self.dismissView = dismissView
    dismissView.addToContainer(containerView)
    
    // Configure the top knob view
    if self.topKnobVisualEffectView == nil, let presentedView = self.presentedView {
      
      // Crate the knob view
      let topKnobVisualEffectView = TopKnobVisualEffectView.newView()
      let knobViewRequiredOffset = TopKnobVisualEffectView.topKnobSpace + TopKnobVisualEffectView.knobHeight + TopKnobVisualEffectView.bottomKnobSpace
      topKnobVisualEffectView.addToContainer(presentedView, atIndex: 0, topMargin: -knobViewRequiredOffset)
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
    let preferredHeight = self.presentedViewController.preferredContentSize.height
    let knobViewRequiredOffset = TopKnobVisualEffectView.topKnobSpace + TopKnobVisualEffectView.knobHeight + TopKnobVisualEffectView.bottomKnobSpace
    let height: CGFloat = preferredHeight + knobViewRequiredOffset
    return CGRect(x: 0, y: containerBounds.height - height, width: containerBounds.width, height: height)
  }
  
  // MARK: - Actions
  
  @objc func dismissController() {
    self.presentingViewController.dismiss(animated: true, completion: nil)
  }
}
