//
//  MainViewController+PresentingViewControllerDelegate.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/10/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

extension MainViewController : PresentingViewControllerDelegate {
  
  func willPresentViewController(_ viewController: UIViewController) {
    self.disableAllElements()
  }
  
  func isPresentingViewController(_ viewController: UIViewController?) {
    self.hideAllElements()
  }
  
  func didPresentViewController(_ viewController: UIViewController?) {
    self.hideAllElements()
    
    if let _ = viewController as? ConfiguringViewController {
      switch self.arViewController?.state ?? .normal {
      case .normal:
        self.hideConfiguringView()
      default: break
      }
    }
  }
  
  func willDismissViewController(_ viewController: UIViewController) {}
  
  func isDismissingViewController(_ viewController: UIViewController?) {
    self.showAllElements()
  }
  
  func didDismissViewController(_ viewController: UIViewController?) {
    
    // All presentations
    self.enableAllElements()
  }
  
  func didCancelDissmissViewController(_ viewController: UIViewController?) {
    self.hideAllElements()
    self.disableAllElements()
  }
}
