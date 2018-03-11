//
//  MainViewController+HomeTabBarViewDelegate.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/10/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

extension MainViewController : HomeTabBarViewDelegate, SettingsNavigationDelegate, ModeChooserNavigationDelegate, MyPlacemarksNavigationDelegate, FoodNearbyNavigationDelegate {
  
  func tabButtonSelected(type: HomeTabBarButtonType) {
    switch type {
    case .mode:
      self.presentModeChooser(delegate: self, options: [ .presentingViewControllerDelegate(self) ])
    case .settings:
      self.presentSettings(options: [ .presentingViewControllerDelegate(self) ])
      
    case .myPlacemarkAdd:
      self.presentAddLocation(addLocationDelegate: self, searchDelegate: self, options: [ .presentingViewControllerDelegate(self) ])
    case .myPlacemarkList:
      self.presentPlacemarkList(delegate: self, options: [ .presentingViewControllerDelegate(self) ])
      
    case .foodNearbyFavorites: break
    case .foodNearbyList:
      self.presentFoodNearbySearch(delegate: self, options: [ .presentingViewControllerDelegate(self) ])
      
    case .mountainList: break
    }
  }
}
