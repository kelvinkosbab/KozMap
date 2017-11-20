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
  
  func add(childViewController: UIViewController, intoContainerView containerView: UIView) {
    childViewController.view.translatesAutoresizingMaskIntoConstraints = false
    self.addChildViewController(childViewController)
    childViewController.view.frame = containerView.frame
    containerView.addSubview(childViewController.view)
    childViewController.didMove(toParentViewController: self)
    
    // Set up constraints for the embedded controller
    if #available(iOS 11, *) {
      let guide = containerView.safeAreaLayoutGuide
      NSLayoutConstraint.activate([
        childViewController.view.topAnchor.constraint(equalTo: guide.topAnchor, constant: 0),
        guide.bottomAnchor.constraint(equalTo: childViewController.view.bottomAnchor, constant: 0),
        childViewController.view.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 0),
        guide.trailingAnchor.constraint(equalTo: childViewController.view.trailingAnchor, constant: 0)
        ])
    } else {
      NSLayoutConstraint.activate([
        childViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0),
        containerView.bottomAnchor.constraint(equalTo: childViewController.view.bottomAnchor, constant: 0),
        childViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
        containerView.trailingAnchor.constraint(equalTo: childViewController.view.trailingAnchor, constant: 0)
        ])
    }
    containerView.layoutIfNeeded()
    
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
