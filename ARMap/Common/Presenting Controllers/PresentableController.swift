//
//  PresentableController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit

protocol PresentableController : class {
  var presentedMode: PresentationMode { get set }
  var presentationManager: UIViewControllerTransitioningDelegate? { get set }
  var currentFlowInitialController: PresentableController? { get set }
  func present(viewController: UIViewController, withMode mode: PresentationMode, options: [PresentableControllerOption])
  func dismissController(completion: (() -> Void)?)
  func dismissCurrentNavigationFlow(completion: (() -> Void)?)
}

extension PresentableController where Self : UIViewController {
  
  func present(viewController: UIViewController, withMode mode: PresentationMode, options: [PresentableControllerOption] = []) {
    
    // Configure the view controller to present
    let viewControllerToPresent: UIViewController = mode.isNavStack ? viewController : options.inNavigationController ? BaseNavigationController(rootViewController: viewController) : viewController
    
    // Configure the initial flow controller
    if let presentableController = viewController as? PresentableController {
      presentableController.presentedMode = mode
      if !mode.isNavStack {
        presentableController.currentFlowInitialController = self
      }
    }
    
    // Present the controller
    switch mode {
    case .modal(let presentationStyle, let transitionStyle):
      viewControllerToPresent.modalPresentationStyle = presentationStyle
      viewControllerToPresent.modalTransitionStyle = transitionStyle
      viewControllerToPresent.modalPresentationCapturesStatusBarAppearance = true
      self.present(viewControllerToPresent, animated: true, completion: nil)
      
    case .custom(let customPresentationMode):
      viewControllerToPresent.modalPresentationStyle = .custom
      viewControllerToPresent.modalPresentationCapturesStatusBarAppearance = true
      
      // Configure the presenation manager
      let presentationManager = CustomPresentationManager(mode: customPresentationMode)
      presentationManager.presentingViewControllerDelegate = options.presentingViewControllerDelegate
      presentationManager.presentedViewControllerDelegate = options.presentedViewControllerDelegate
      viewControllerToPresent.transitioningDelegate = presentationManager
      if let presentedPresentableController = viewControllerToPresent as? PresentableController {
        presentedPresentableController.presentationManager = presentationManager
      }
      self.present(viewControllerToPresent, animated: true, completion: nil)
      
    case .navStack:
      self.navigationController?.pushViewController(viewControllerToPresent, animated: true)
    }
  }
  
  func dismissController(completion: (() -> Void)? = nil) {
    switch self.presentedMode {
    case .navStack:
      
      guard let navigationController = self.navigationController, let index = navigationController.viewControllers.index(of: self), index > 0 else {
        self.presentingViewController?.dismiss(animated: true, completion: completion)
        return
      }
      
      // Pop to the controller before this one
      let viewControllerToPopTo = navigationController.viewControllers[index - 1]
      navigationController.popToViewController(viewControllerToPopTo, animated: true)
      
    default:
      self.presentingViewController?.dismiss(animated: true, completion: completion)
    }
  }
  
  func dismissCurrentNavigationFlow(completion: (() -> Void)? = nil) {
    guard let currentFlowInitialController = self.currentFlowInitialController else {
      self.dismissController(completion: completion)
      return
    }
    currentFlowInitialController.dismissController(completion: completion)
  }
}
