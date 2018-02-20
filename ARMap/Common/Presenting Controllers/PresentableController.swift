//
//  PresentableController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit

// MARK: - PresentableControllerOption

enum PresentableControllerOption {
  case withoutNavigationController, presentingViewControllerDelegate(PresentingViewControllerDelegate), presentedViewControllerDelegate(PresentedViewControllerDelegate)
}

extension Sequence where Iterator.Element == PresentableControllerOption {
  
  var inNavigationController: Bool {
    return !self.contains { option -> Bool in
      switch option {
      case .withoutNavigationController:
        return true
      default:
        return false
      }
    }
  }
  
  var presentingViewControllerDelegate: PresentingViewControllerDelegate? {
    for option in self {
      switch option {
      case .presentingViewControllerDelegate(let presentingViewControllerDelegate):
        return presentingViewControllerDelegate
      default: break
      }
    }
    return nil
  }
  
  var presentedViewControllerDelegate: PresentedViewControllerDelegate? {
    for option in self {
      switch option {
      case .presentedViewControllerDelegate(let presentedViewControllerDelegate):
        return presentedViewControllerDelegate
      default: break
      }
    }
    return nil
  }
}

// MARK: - PresentationMode

enum PresentationMode {
//  case  leftMenu, rightToLeft, topDown
  
  case modal, modalOverCurrentContext, overCurrentContext
  case topDown, bottomUp, topKnobBottomUp, visualEffectFade
  case navStack
  
  var presentationManager: PresentableManager? {
    switch self {
    case .topDown:
      return TopDownPresentationManager()
    case .bottomUp:
      return BottomUpPresentationManager()
    case .topKnobBottomUp:
      return TopKnobBottomUpPresentationManager()
    case .visualEffectFade:
      return VisualEffectFadePresentationManager()
    default:
      return nil
    }
  }
}

// MARK: - PresentableController

protocol PresentableController : class {
  var presentedMode: PresentationMode { get set }
  var presentationManager: UIViewControllerTransitioningDelegate? { get set }
  var currentFlowFirstController: PresentableController? { get set }
  func present(viewController: UIViewController, withMode mode: PresentationMode, options: [PresentableControllerOption], completion: (() -> Void)?)
  func dismissController(completion: (() -> Void)?)
  func dismissCurrentNavigationFlow(completion: (() -> Void)?)
}

extension PresentableController where Self : UIViewController {
  
  func present(viewController: UIViewController, withMode mode: PresentationMode, options: [PresentableControllerOption] = [], completion: (() -> Void)? = nil) {
    
    // Configure the view controller to present
    let inNavigationController = options.inNavigationController
    let presentingPresentableController: PresentableController? = viewController as? PresentableController
    presentingPresentableController?.presentedMode = mode
    let viewControllerToPresent: UIViewController = mode != .navStack && inNavigationController ? BaseNavigationController(rootViewController: viewController) : viewController
    
    // Presentation manager
    if let presentationManager = mode.presentationManager {
      presentationManager.presentingViewControllerDelegate = options.presentingViewControllerDelegate
      presentationManager.presentedViewControllerDelegate = options.presentedViewControllerDelegate
      viewControllerToPresent.transitioningDelegate = presentationManager
      if let presentableController = viewControllerToPresent as? PresentableController {
        presentableController.presentationManager = presentationManager
      }
    }
    
    // Present the controller
    switch mode {
    case .modal:
      presentingPresentableController?.currentFlowFirstController = self
      if UIDevice.current.isPhone {
        viewControllerToPresent.modalTransitionStyle = .coverVertical
        viewControllerToPresent.modalPresentationStyle = .overFullScreen
        viewControllerToPresent.modalPresentationCapturesStatusBarAppearance = true
      } else {
        viewControllerToPresent.modalPresentationStyle = .formSheet
      }
      self.present(viewControllerToPresent, animated: true, completion: completion)
      
    case .modalOverCurrentContext:
      presentingPresentableController?.currentFlowFirstController = self
      if UIDevice.current.isPhone {
        viewControllerToPresent.modalTransitionStyle = .coverVertical
        viewControllerToPresent.modalPresentationStyle = .overFullScreen
        viewControllerToPresent.modalPresentationCapturesStatusBarAppearance = true
      } else {
        viewControllerToPresent.modalPresentationStyle = .overCurrentContext
      }
      self.present(viewControllerToPresent, animated: true, completion: completion)
      
    case .overCurrentContext:
      presentingPresentableController?.currentFlowFirstController = self
      viewControllerToPresent.modalPresentationStyle = .overCurrentContext
      viewControllerToPresent.modalTransitionStyle = .crossDissolve
      self.present(viewController, animated: true, completion: completion)
      
//    case .leftMenu:
//      presentingPresentableController?.currentFlowFirstController = self
//      let presentationManager = LeftMenuPresentationManager(dismissInteractor: DragLeftDismissInteractiveTransition(presentingController: viewControllerToPresent, interactiveView: dismissInteractiveElement?.view))
//      presentationManager.presentingViewControllerDelegate = presentingViewControllerDelegate
//      viewControllerToPresent.modalPresentationStyle = .custom
//      viewControllerToPresent.modalPresentationCapturesStatusBarAppearance = true
//      viewControllerToPresent.transitioningDelegate = presentationManager
//      viewControllerToPresentPresentableController?.presentationManager = presentationManager
//      self.present(viewControllerToPresent, animated: true, completion: completion)
//
//    case .rightToLeft:
//      presentingPresentableController?.currentFlowFirstController = self
//      let presentationManager = RightToLeftPresentationManager(dismissInteractor: DragRightDismissInteractiveTransition(presentingController: viewControllerToPresent, interactiveView: dismissInteractiveElement?.view))
//      presentationManager.presentingViewControllerDelegate = presentingViewControllerDelegate
//      viewControllerToPresent.modalPresentationStyle = .custom
//      viewControllerToPresent.modalPresentationCapturesStatusBarAppearance = true
//      viewControllerToPresent.transitioningDelegate = presentationManager
//      viewControllerToPresentPresentableController?.presentationManager = presentationManager
//      self.present(viewControllerToPresent, animated: true, completion: completion)
      
    case .topDown, .bottomUp, .topKnobBottomUp, .visualEffectFade:
      presentingPresentableController?.currentFlowFirstController = self
      viewControllerToPresent.modalPresentationStyle = .custom
      viewControllerToPresent.modalPresentationCapturesStatusBarAppearance = true
      self.present(viewControllerToPresent, animated: true, completion: completion)
      
    case .navStack:
      self.navigationController?.pushViewController(viewControllerToPresent, animated: true)
      completion?()
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
    guard let currentFlowFirstController = self.currentFlowFirstController else {
      self.dismissController(completion: completion)
      return
    }
    currentFlowFirstController.dismissController(completion: completion)
  }
}
