//
//  ModeChooserNavigationDelegate.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/9/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

protocol ModeChooserNavigationDelegate : class {}
extension ModeChooserNavigationDelegate where Self : UIViewController {
  
  func presentModeChooser(delegate: ModeChooserDelegate?, options: [PresentableControllerOption] = []) {
    
    guard self.presentedViewController == nil else {
      return
    }
    
    let modeChooserViewController = ModeChooserViewController.newViewController(delegate: delegate)
    modeChooserViewController.presentIn(self, withMode: .custom(.visualEffectFade), options: options)
  }
}
