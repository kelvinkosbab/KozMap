//
//  ConfiguringViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/20/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit

enum ConfiguringState {
  case na, statusMessage(String?, String?)
}

class ConfiguringViewController : BaseViewController {
  
  // MARK: - Static Accessors
  
  private static func newViewController() -> ConfiguringViewController {
    return self.newViewController(fromStoryboardWithName: "Configuring")
  }
  
  static func newViewController(state: ConfiguringState) -> ConfiguringViewController {
    let viewController = self.newViewController()
    viewController.state = state
    return viewController
  }
  
  // MARK: - Properties
  
  @IBOutlet private weak var statusLabel: UILabel!
  @IBOutlet private weak var messageLabel: UILabel!
  
  var state: ConfiguringState = .na {
    didSet {
      if self.isViewLoaded {
        self.updateContent()
      }
    }
  }
  
  // MARK: - Lifecycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.updateContent()
  }
  
  // MARK: - Status Bar
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: - Content
  
  func updateContent() {
    switch self.state {
    case .statusMessage(let status, let message):
      self.statusLabel.text = status
      self.messageLabel.text = message
    case .na:
      self.statusLabel.text = ""
      self.messageLabel.text = ""
    }
  }
}
