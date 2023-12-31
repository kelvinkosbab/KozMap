//
//  CustomPresentationController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 2/19/18.
//  Copyright © 2018 Kozinga. All rights reserved.
//

import UIKit

class CustomPresentationController : UIPresentationController {
  
  var presentationInteractiveTransition: InteractiveTransition?
  var dismissInteractiveTransition: InteractiveTransition?
  
  override func containerViewWillLayoutSubviews() {
    super.containerViewWillLayoutSubviews()
    
    self.presentedView?.frame = self.frameOfPresentedViewInContainerView
  }
}

extension CustomPresentationController {
  
  // MARK: - Interactive Views
  
  internal var allPresentationInteractiveViews: [UIView] {
    var interactiveViews: [UIView] = []
    
    // Presenting view controller
    if let presentationInteractable = self.presentingViewController.topViewController as? PresentationInteractable, presentationInteractable.presentationInteractiveViews.count > 0 {
      interactiveViews += presentationInteractable.presentationInteractiveViews
    }
    
    // Presenting controller
    if let presentationInteractable = self as? PresentationInteractable, presentationInteractable.presentationInteractiveViews.count > 0 {
      interactiveViews += presentationInteractable.presentationInteractiveViews
    }
    
    return interactiveViews
  }
  
  internal var allDismissInteractiveViews: [UIView] {
    var interactiveViews: [UIView] = []
    
    // Presented view controller
    if let dismissInteractable = self.presentedViewController.topViewController as? DismissInteractable, dismissInteractable.dismissInteractiveViews.count > 0 {
      interactiveViews += dismissInteractable.dismissInteractiveViews
    }
    
    // Presenting controller
    if let dismissInteractable = self as? DismissInteractable, dismissInteractable.dismissInteractiveViews.count > 0 {
      interactiveViews += dismissInteractable.dismissInteractiveViews
    }
    
    return interactiveViews
  }
  
  // MARK: - Scroll View Interactive
  
  internal var scrollViewInteractiveSenderDelegate: ScrollViewInteractiveSenderDelegate? {
    return self.presentedViewController.topViewController as? ScrollViewInteractiveSenderDelegate
  }
}
