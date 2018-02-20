//
//  BottomUpPresentationController.swift
//  ARMap
//
//  Created by Kelvin Kosbab on 2/19/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

class BottomUpPresentationController : UIPresentationController {
  
  // MARK: - Properties
  
  private var dismissView: UIView? = nil
  
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
  }
  
  override func presentationTransitionDidEnd(_ completed: Bool) {
    if !completed {
      self.dismissView?.removeFromSuperview()
      self.dismissView = nil
    }
  }
  
  override var frameOfPresentedViewInContainerView: CGRect {
    let containerBounds = self.containerView?.bounds ?? UIScreen.main.bounds
    let preferredHeight = self.presentedViewController.preferredContentSize.height
    return CGRect(x: 0, y: containerBounds.height - preferredHeight, width: containerBounds.width, height: preferredHeight)
  }
  
  // MARK: - Actions
  
  @objc func dismissController() {
    self.presentingViewController.dismiss(animated: true, completion: nil)
  }
}
