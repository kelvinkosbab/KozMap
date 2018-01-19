//
//  UICollectionView+Util.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/7/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit

extension UICollectionView {
  
  // When embedding a collection view as a child view controller in a container view more configuration is necessary to get reordering to work properly. This should be called in segue or when programmatically adding this controller to another view controller
  
  func configureLongPressReordering() {
    let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleCollectionViewLongGesture(_:)))
    self.addGestureRecognizer(gesture)
  }
  
  @objc func handleCollectionViewLongGesture(_ gesture: UILongPressGestureRecognizer) {
    switch(gesture.state) {
    case .began:
      if let selectedIndexPath = self.indexPathForItem(at: gesture.location(in: self)) {
        self.beginInteractiveMovementForItem(at: selectedIndexPath)
      }
    case .changed:
      self.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view))
    case .ended:
      self.endInteractiveMovement()
    default:
      self.cancelInteractiveMovement()
    }
  }
}
