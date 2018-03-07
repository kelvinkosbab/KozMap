//
//  MainViewController+AppMode.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 3/7/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

extension MainViewController : ModeChooserDelegate {
  
  func didChooseMode(_ mode: AppMode, sender: PresentableController) {
    sender.dismissController {
      
    }
  }
}
