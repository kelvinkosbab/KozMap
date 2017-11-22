//
//  UIViewController+Util.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/7/17.
//  Copyright © 2017 Kozinga. All rights reserved.
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
}
