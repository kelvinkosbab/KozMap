//
//  PresentableManager.swift
//  ARMap
//
//  Created by Kelvin Kosbab on 2/19/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

protocol PresentableManager : UIViewControllerTransitioningDelegate {
  
  var presentationController: UIPresentationController? { get set }
  
  var presentationInteractiveTransition: InteractiveTransition? { get set }
  var dismissInteractiveTransition: InteractiveTransition? { get set }
  
  var presentingViewControllerDelegate: PresentingViewControllerDelegate? { get set }
  var presentedViewControllerDelegate: PresentedViewControllerDelegate? { get set }
}

extension PresentableManager {
  
  var presentingViewController: UIViewController? {
    return self.presentationController?.presentingViewController
  }
  
  var presentedViewController: UIViewController? {
    return self.presentationController?.presentedViewController
  }
  
  private var presentationInteractiveView: UIView? {
    if let presentationInteractable = self.presentingViewController as? PresentationInteractable, let presentationInteractiveView = presentationInteractable.presentationInteractiveView {
      return presentationInteractiveView
    }
    return nil
  }
  
  internal var presentationInteractiveViews: [UIView] {
    var interactiveViews: [UIView] = []
    
    if let presentationInteractiveView = self.presentationInteractiveView {
      interactiveViews.append(presentationInteractiveView)
    }
    
    if let presentationInteractable = self.presentationController as? PresentationInteractable, let presentationInteractiveView = presentationInteractable.presentationInteractiveView {
      interactiveViews.append(presentationInteractiveView)
    }
    
    return interactiveViews
  }
  
  private var dismissInteractiveView: UIView? {
    if let dismissInteractable = self.presentedViewController as? DismissInteractable, let dismissInteractiveView = dismissInteractable.dismissInteractiveView {
      return dismissInteractiveView
    }
    return nil
  }
  
  internal var dismissInteractiveViews: [UIView] {
    var interactiveViews: [UIView] = []
    
    if let dismissInteractiveView = self.dismissInteractiveView {
      interactiveViews.append(dismissInteractiveView)
    }
    
    if let dismissInteractable = self.presentationController as? DismissInteractable, let dismissInteractiveView = dismissInteractable.dismissInteractiveView {
      interactiveViews.append(dismissInteractiveView)
    }
    
    return interactiveViews
  }
}
