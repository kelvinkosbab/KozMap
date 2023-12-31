//
//  FoodNearbyNavigationDelegate.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/9/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

protocol FoodNearbyNavigationDelegate : class {}
extension FoodNearbyNavigationDelegate where Self : BaseViewController {
  
  func presentFoodNearbySearch(delegate: SearchFoodNearbyViewControllerDelegate? = nil, options: [PresentableControllerOption] = []) {
    let searchFoodNearbyViewController = SearchFoodNearbyViewController.newViewController(delegate: delegate)
    if UIDevice.current.isPhone {
      searchFoodNearbyViewController.presentIn(self, withMode: .custom(.topKnobBottomUp), options: options)
    } else {
      searchFoodNearbyViewController.presentIn(self, withMode: .modal(.formSheet, .coverVertical), options: options)
    }
  }
}
