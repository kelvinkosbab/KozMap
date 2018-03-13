//
//  PlacemarkDetailNavigationDelegate.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/13/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

protocol PlacemarkDetailNavigationDelegate : class {}
extension PlacemarkDetailNavigationDelegate where Self : UIViewController {
  
  private func getLocationDetailViewController(placemark: Placemark) -> LocationDetailViewController {
    return LocationDetailViewController.newViewController(placemark: placemark)
  }
  
  func presentLocationDetail(placemark: Placemark, options: [PresentableControllerOption] = []) {
    let locationDetailViewController = self.getLocationDetailViewController(placemark: placemark)
    if UIDevice.current.isPhone {
      let inNavigationController: Bool = placemark.placemarkType != .myPlacemark
      let navigationControllerOptions: [PresentableControllerOption] = inNavigationController ? [] : [ .withoutNavigationController ]
      locationDetailViewController.presentIn(self, withMode: .custom(.topKnobBottomUp), options: navigationControllerOptions + options)
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
