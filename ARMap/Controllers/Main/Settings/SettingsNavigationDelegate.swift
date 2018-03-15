//
//  SettingsNavigationDelegate.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/10/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

protocol SettingsNavigationDelegate : class {}
extension SettingsNavigationDelegate where Self : UIViewController {
  
  func presentSettings(options: [PresentableControllerOption] = []) {
    let settingsViewController = SettingsViewController.newViewController()
    if UIDevice.current.isPhone {
      settingsViewController.presentIn(self, withMode: .custom(.topKnobBottomUp), options: options)
    } else {
      settingsViewController.presentIn(self, withMode: .modal(.formSheet, .coverVertical), options: options)
    }
  }
}
