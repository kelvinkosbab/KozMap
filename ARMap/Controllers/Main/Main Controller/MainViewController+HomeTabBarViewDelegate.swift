//
//  MainViewController+HomeTabBarViewDelegate.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/10/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

extension MainViewController : HomeTabBarViewDelegate, SettingsNavigationDelegate, ModeChooserNavigationDelegate, PlacemarkDetailNavigationDelegate, PlacemarkListNavigationDelegate, MyPlacemarksNavigationDelegate, FoodNearbyNavigationDelegate {
  
  func tabButtonSelected(type: HomeTabBarButtonType) {
    switch type {
    case .mode:
      self.presentModeChooser(delegate: self, options: [ .presentingViewControllerDelegate(self) ])
    case .settings:
      self.presentSettings(options: [ .presentingViewControllerDelegate(self) ])
      
    case .myPlacemarkAdd:
      self.presentAddLocation(addLocationDelegate: self, searchDelegate: self, options: [ .presentingViewControllerDelegate(self) ])
    case .myPlacemarkList:
      self.presentPlacemarkList(appMode: self.appMode, delegate: self, options: [ .presentingViewControllerDelegate(self) ])
      
    case .foodNearbyFavorites:
      self.presentPlacemarkList(appMode: self.appMode, delegate: self, options: [ .presentingViewControllerDelegate(self) ])
    case .foodNearbyList:
      self.presentFoodNearbySearch(delegate: self, options: [ .presentingViewControllerDelegate(self) ])
      
    case .mountainList: break
    }
  }
}

// MARK: - LocationListViewControllerDelegate

extension MainViewController : LocationListViewControllerDelegate {
  
  func shouldShowPlacemarkDetail(placemark: Placemark, sender: UIViewController) {
    self.dismissPresented { [weak self] in
      
      // Present an alert
      self?.presentLocationDetail(placemark: placemark)
    }
  }
  
  func shouldTransitionToAdd(sender: UIViewController) {
    self.dismissPresented { [weak self] in
      
      guard let strongSelf = self else {
        return
      }
      
      switch strongSelf.appMode {
      case .myPlacemark:
        strongSelf.presentAddLocation(addLocationDelegate: strongSelf, searchDelegate: strongSelf, options: [ .presentingViewControllerDelegate(strongSelf) ])
      case .food: break
      case .mountain: break
      }
    }
  }
  
  func shouldTransitionToSearch(sender: UIViewController) {
    self.dismissPresented { [weak self] in
      
      guard let strongSelf = self else {
        return
      }
      
      switch strongSelf.appMode {
      case .myPlacemark: break
      case .food:
        strongSelf.presentFoodNearbySearch(delegate: strongSelf, options: [ .presentingViewControllerDelegate(strongSelf) ])
      case .mountain: break
      }
    }
  }
}

// MARK: - SearchViewControllerDelegate

extension MainViewController : MyPlacemarkSearchViewControllerDelegate {
  
  func shouldAdd(mapItem: MapItem) {
    self.dismissPresented { [weak self] in
      
      guard let strongSelf = self else {
        return
      }
      
      strongSelf.presentAddLocation(mapItem: mapItem, delegate: strongSelf, options: [ .presentingViewControllerDelegate(strongSelf) ])
    }
  }
}

// MARK: - SearchFoodNearbyViewControllerDelegate

extension MainViewController : SearchFoodNearbyViewControllerDelegate {
  
  func didSelectPlacemark(_ placemark: Placemark, sender: UIViewController) {
    self.dismissPresented { [weak self] in
      
      guard let strongSelf = self else {
        return
      }
      
      strongSelf.presentLocationDetail(placemark: placemark, options: [ .presentingViewControllerDelegate(strongSelf) ])
    }
  }
}
