//
//  ConfiguringViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/20/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import UIKit

class ConfiguringViewController : BaseViewController {
  
  // MARK: - Static Accessors
  
  private static func newViewController() -> ConfiguringViewController {
    return self.newViewController(fromStoryboardWithName: "Main")
  }
  
  static func newViewController(status: String?) -> ConfiguringViewController {
    let viewController = self.newViewController()
    viewController.status = status
    return viewController
  }
  
  // MARK: - Properties
  
  @IBOutlet private weak var statusLabel: UILabel!
  
  var status: String? = nil {
    didSet {
      if self.isViewLoaded {
        self.statusLabel.text = self.status
      }
    }
  }
  
  // MARK: - Lifecycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.statusLabel.text = self.status
  }
}
