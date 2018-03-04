//
//  LocationDetailNavigationDelegate.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/3/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

protocol LocationDetailNavigationDelegate : class {}
extension LocationDetailNavigationDelegate where Self : UIViewController {
  
  func getPlacemarkDetailViewController(placemark: Placemark) -> LocationDetailViewController {
    return LocationDetailViewController.newViewController(placemark: placemark)
  }
}
