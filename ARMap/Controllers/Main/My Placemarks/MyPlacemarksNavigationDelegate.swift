//
//  MyPlacemarksNavigationDelegate.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/10/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

protocol MyPlacemarksNavigationDelegate : class {}
extension MyPlacemarksNavigationDelegate where Self : UIViewController {
  
  // MARK: - Add Placemark
  
  func presentAddLocation(addLocationDelegate: AddLocationViewControllerDelegate?, searchDelegate: MyPlacemarkSearchViewControllerDelegate?, options: [PresentableControllerOption] = []) {
    let addLocationContainerViewController = AddLocationContainerViewController.newViewController(locationDetailDelegate: addLocationDelegate, searchDelegate: searchDelegate)
    if UIDevice.current.isPhone {
      addLocationContainerViewController.presentIn(self, withMode: .custom(.topKnobBottomUp), options: options)
    } else {
      addLocationContainerViewController.presentIn(self, withMode: .modal(.formSheet, .coverVertical), options: options)
    }
  }
  
  func presentAddLocation(mapItem: MapItem, delegate: AddLocationViewControllerDelegate?, options: [PresentableControllerOption] = []) {
    let addLocationViewController = AddLocationViewController.newViewController(mapItem: mapItem, delegate: delegate)
    if UIDevice.current.isPhone {
      addLocationViewController.presentIn(self, withMode: .custom(.topKnobBottomUp), options: options)
    } else {
      addLocationViewController.presentIn(self, withMode: .modal(.formSheet, .coverVertical), options: options)
    }
  }
}
