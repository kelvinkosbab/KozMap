//
//  UIViewController+Util.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/7/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit

extension UIViewController {
  
  // MARK: - Add Child View Controller
  
  func add(childViewController: UIViewController, intoContainerView containerView: UIView, relativeLayoutType: UIView.RelativeLayoutType = .view) {
    childViewController.view.translatesAutoresizingMaskIntoConstraints = false
    self.addChildViewController(childViewController)
    childViewController.view.frame = containerView.frame
    childViewController.view.addToContainer(containerView, relativeLayoutType: relativeLayoutType)
    childViewController.didMove(toParentViewController: self)
    
    // Check if this view is a collection view, if so need to configure it for long-press reordering
    if let collectionViewController = childViewController as? UICollectionViewController {
      collectionViewController.collectionView?.configureLongPressReordering()
    }
  }
  
  // MARK: - Remove Child View Controller
  
  func remove(childViewController: UIViewController) {
    childViewController.willMove(toParentViewController: nil)
    childViewController.view.removeFromSuperview()
    childViewController.removeFromParentViewController()
  }
  
  // MARK: - Dismissing Presented View Controllers
  
  func dismissPresented(completion: (() -> Void)? = nil) {
    
    guard let _ = self.presentedViewController else {
      completion?()
      return
    }
    
    self.dismiss(animated: true, completion: completion)
  }
  
  // MARK: - Top View Controller
  
  var topViewController: UIViewController {
    
    var topViewController = self
    while let presentedViewController = topViewController.presentedViewController {
      topViewController = presentedViewController
    }
    
    // Check for UITabBarController
    if let tabBarController = topViewController as? UITabBarController, let selectedViewController = tabBarController.viewControllers?[tabBarController.selectedIndex] {
      topViewController = selectedViewController.topViewController
    }
    
    // Check for UINavigationBarController
    if let navigationController = topViewController as? UINavigationController, let lastViewController = navigationController.viewControllers.last {
      topViewController = lastViewController.topViewController
    }
    
    // Completion
    return topViewController
  }
}
