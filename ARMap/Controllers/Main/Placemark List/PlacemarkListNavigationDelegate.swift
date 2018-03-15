//
//  PlacemarkListNavigationDelegate.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/13/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

protocol PlacemarkListNavigationDelegate : class {}
extension PlacemarkListNavigationDelegate where Self : UIViewController {
  
  func presentPlacemarkList(appMode: AppMode, delegate: LocationListViewControllerDelegate?, options: [PresentableControllerOption] = []) {
    let locationListViewController = LocationListViewController.newViewController(appMode: appMode, delegate: delegate)
    if UIDevice.current.isPhone {
      locationListViewController.presentIn(self, withMode: .custom(.topKnobBottomUp), options: options)
    } else {
      locationListViewController.presentIn(self, withMode: .modal(.formSheet, .coverVertical), options: options)
    }
  }
}
