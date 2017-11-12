//
//  SearchViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/12/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import UIKit

class SearchViewController : BaseTableViewController {
  
  // MARK: - Static Accessors
  
  static func newViewController() -> SearchViewController {
    return self.newViewController(fromStoryboardWithName: "AddLocation")
  }
  
  // MARK: - Lifecycle
}
