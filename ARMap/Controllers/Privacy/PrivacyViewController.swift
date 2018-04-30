//
//  PrivacyViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 4/28/18.
//  Copyright © 2018 Tack Mobile. All rights reserved.
//

import UIKit

class PrivacyViewController : BaseViewController, DismissInteractable {
  
  // MARK: - Static Accessors
  
  static func newViewController() -> PrivacyViewController {
    return self.newViewController(fromStoryboardWithName: "Privacy")
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var analyticsCollectionSwitch: UISwitch!
  
  var defaults: Defaults {
    return Defaults.shared
  }
  
  // MARK: - DismissInteractable
  
  var dismissInteractiveViews: [UIView] {
    var views: [UIView] = []
    if let view = self.view {
      views.append(view)
    }
    return views
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Privacy"
    
    self.navigationItem.largeTitleDisplayMode = UIDevice.current.isPhone ? .never : .always
    if UIDevice.current.isPhone {
      self.baseNavigationController?.navigationBarStyle = .transparentBlueTint
      self.view.backgroundColor = .clear
      
      // Back button
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: LocalizedString.cancel, style: .plain, target: self, action: #selector(self.backButtonSelected))
      
    } else {
      self.baseNavigationController?.navigationBarStyle = .standard
      self.view.backgroundColor = .white
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.reloadContent()
  }
  
  // MARK: - Content
  
  func reloadContent() {
    self.analyticsCollectionSwitch.isOn = self.defaults.isAnalyticsCollectionEnabled
  }
  
  // MARK: - Actions
  
  @objc func backButtonSelected() {
    self.dismissController()
  }
  
  @IBAction func analyticsCollectionSwitchValueChanged(_ sender: UISwitch) {
    
    // Enable or disable analytics
    AnalyticsManager.shared.setAnalyticsCollectionEnabled(sender.isOn)
    self.defaults.isAnalyticsCollectionEnabled = sender.isOn
    MyDataManager.shared.saveMainContext()
  }
}
