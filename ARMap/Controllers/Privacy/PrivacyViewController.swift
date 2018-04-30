//
//  PrivacyViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 4/28/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

class PrivacyViewController : BaseViewController {
  
  // MARK: - Static Accessors
  
  static func newViewController() -> PrivacyViewController {
    return self.newViewController(fromStoryboardWithName: "Privacy")
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var analyticsCollectionSwitch: UISwitch!
  
  var defaults: Defaults {
    return Defaults.shared
  }
  
  // MARK: - Lifecycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.reloadContent()
  }
  
  // MARK: - Content
  
  func reloadContent() {
    self.analyticsCollectionSwitch.isOn = self.defaults.isAnalyticsCollectionEnabled
  }
  
  // MARK: - Actions
  
  @IBAction func analyticsCollectionSwitchValueChanged(_ sender: UISwitch) {
    
    // Enable or disable analytics
    AnalyticsManager.shared.setAnalyticsCollectionEnabled(sender.isOn)
    self.defaults.isAnalyticsCollectionEnabled = sender.isOn
  }
}
