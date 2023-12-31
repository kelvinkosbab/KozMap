//
//  RootNavigationController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit

class RootNavigationController : BaseNavigationController {
  
  // MARK: - Static Accessors
  
  static var shared: RootNavigationController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    return appDelegate.window!.rootViewController as! RootNavigationController
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationBarStyle = .transparent
  }
}
