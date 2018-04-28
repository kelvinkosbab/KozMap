//
//  PrivacyViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 4/28/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

class PrivacyViewController : BaseTableViewController {
  
  // MARK: - Static Accessors
  
  static func newViewController() -> PrivacyViewController {
    return self.newViewController(fromStoryboardWithName: "Privacy")
  }
}
