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
  
  // MARK: - Placemark List
  
  func presentPlacemarkList(delegate: LocationListViewControllerDelegate?, options: [PresentableControllerOption] = []) {
    let locationListViewController = LocationListViewController.newViewController(delegate: delegate)
    if UIDevice.current.isPhone {
      locationListViewController.presentIn(self, withMode: .custom(.topKnobBottomUp), options: options)
    } else {
      locationListViewController.presentIn(self, withMode: .modal(.formSheet, .coverVertical), options: options)
    }
  }
  
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
      addLocationViewController.presentIn(self, withMode: .custom(.topKnobBottomUp), options: [ .withoutNavigationController ] + options)
    } else {
      addLocationViewController.presentIn(self, withMode: .modal(.formSheet, .coverVertical), options: options)
    }
  }
  
  // MARK: - Placemark Detail
  
  private func getLocationDetailViewController(placemark: Placemark) -> LocationDetailViewController {
    return LocationDetailViewController.newViewController(placemark: placemark)
  }
  
  func presentLocationDetail(placemark: Placemark, options: [PresentableControllerOption] = []) {
    let locationDetailViewController = self.getLocationDetailViewController(placemark: placemark)
    if UIDevice.current.isPhone {
      locationDetailViewController.presentIn(self, withMode: .custom(.topKnobBottomUp), options: [ .withoutNavigationController ] + options)
    } else {
      locationDetailViewController.presentIn(self, withMode: .modal(.formSheet, .coverVertical), options: options)
    }
  }
  
  func pushLocationDetail(placemark: Placemark) {
    let viewController = self.getLocationDetailViewController(placemark: placemark)
    viewController.view.backgroundColor = .white
    viewController.presentIn(self, withMode: .navStack)
  }
}
