//
//  MainViewController+ModeChooserDelegate.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/10/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

// MARK: - ModeChooserDelegate

extension MainViewController : ModeChooserDelegate {
  
  func didChooseMode(_ appMode: AppMode, sender: UIViewController) {
    
    // Dismiss the sender
    sender.dismiss(animated: true, completion: nil)
    
    // Check change in app mode
    guard self.appMode != appMode else {
      return
    }
    
    // Update the mode and the home tab bar
    Defaults.shared.appMode = appMode
    self.appMode = appMode
  }
}
