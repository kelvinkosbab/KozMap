//
//  PresentableController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit

// MARK: - PresentationMode

enum PresentationMode {
  case modal, modalOverCurrentContext, overCurrentContext
  case custom(CustomPresentationMode)
  case navStack
  
  var isNavStack: Bool {
    switch self {
    case .navStack:
      return true
    default:
      return false
    }
  }
}

enum CustomPresentationMode {
  //  case  leftMenu, rightToLeft
  case topDown, bottomUp, topKnobBottomUp, visualEffectFade
  
  var presentationAnimator: PresentableAnimator {
    return self.dissmissAnimator
  }
  
  var dissmissAnimator: PresentableAnimator {
    switch self {
    case .topDown:
      return TopDownAnimator()
    case .bottomUp:
      return BottomUpAnimator()
    case .topKnobBottomUp:
      return TopKnobBottomUpAnimator()
    case .visualEffectFade:
      return VisualEffectFadeAnimator()
    }
  }
  
  func getPresentationController(forPresented presented: UIViewController, presenting: UIViewController) -> CustomPresentationController {
    switch self {
    case .topDown:
      return TopDownPresentationController(presentedViewController: presented, presenting: presenting)
    case .bottomUp:
      return BottomUpPresentationController(presentedViewController: presented, presenting: presenting)
    case .topKnobBottomUp:
      return TopKnobBottomUpPresentationController(presentedViewController: presented, presenting: presenting)
    case .visualEffectFade:
      return VisualEffectFadePresentationController(presentedViewController: presented, presenting: presenting)
    }
  }
}

// MARK: - PresentableController

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
    let inNavigationController = options.inNavigationController
    let viewControllerToPresent: UIViewController = mode.isNavStack && inNavigationController ? BaseNavigationController(rootViewController: viewController) : viewController
    
    // Configure the initial flow controller
    if let presentableController = viewController as? PresentableController, !mode.isNavStack {
      presentableController.currentFlowInitialController = self
      presentableController.presentedMode = mode
    }
    
    // Present the controller
    switch mode {
    case .modal:
      if UIDevice.current.isPhone {
        viewControllerToPresent.modalTransitionStyle = .coverVertical
        viewControllerToPresent.modalPresentationStyle = .overFullScreen
        viewControllerToPresent.modalPresentationCapturesStatusBarAppearance = true
      } else {
        viewControllerToPresent.modalPresentationStyle = .formSheet
      }
      self.present(viewControllerToPresent, animated: true, completion: nil)
      
    case .modalOverCurrentContext:
      if UIDevice.current.isPhone {
        viewControllerToPresent.modalTransitionStyle = .coverVertical
        viewControllerToPresent.modalPresentationStyle = .overFullScreen
        viewControllerToPresent.modalPresentationCapturesStatusBarAppearance = true
      } else {
        viewControllerToPresent.modalPresentationStyle = .overCurrentContext
      }
      self.present(viewControllerToPresent, animated: true, completion: nil)
      
    case .overCurrentContext:
      viewControllerToPresent.modalPresentationStyle = .overCurrentContext
      viewControllerToPresent.modalTransitionStyle = .crossDissolve
      self.present(viewController, animated: true, completion: nil)
      
//    case .leftMenu:
//      presentingPresentableController?.currentFlowInitialController = self
//      let presentationManager = LeftMenuPresentationManager(dismissInteractor: DragLeftDismissInteractiveTransition(presentingController: viewControllerToPresent, interactiveView: dismissInteractiveElement?.view))
//      presentationManager.presentingViewControllerDelegate = presentingViewControllerDelegate
//      viewControllerToPresent.modalPresentationStyle = .custom
//      viewControllerToPresent.modalPresentationCapturesStatusBarAppearance = true
//      viewControllerToPresent.transitioningDelegate = presentationManager
//      viewControllerToPresentPresentableController?.presentationManager = presentationManager
//      self.present(viewControllerToPresent, animated: true, completion: completion)
//
//    case .rightToLeft:
//      presentingPresentableController?.currentFlowInitialController = self
//      let presentationManager = RightToLeftPresentationManager(dismissInteractor: DragRightDismissInteractiveTransition(presentingController: viewControllerToPresent, interactiveView: dismissInteractiveElement?.view))
//      presentationManager.presentingViewControllerDelegate = presentingViewControllerDelegate
//      viewControllerToPresent.modalPresentationStyle = .custom
//      viewControllerToPresent.modalPresentationCapturesStatusBarAppearance = true
//      viewControllerToPresent.transitioningDelegate = presentationManager
//      viewControllerToPresentPresentableController?.presentationManager = presentationManager
//      self.present(viewControllerToPresent, animated: true, completion: completion)
      
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
