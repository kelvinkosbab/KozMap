//
//  SettingsViewController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import UIKit

class SettingsViewController : BaseViewController {
  
  // MARK: - Static Accessors
  
  static func newViewController() -> SettingsViewController {
    return self.newViewController(fromStoryboardWithName: "Main")
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var versionLabel: UILabel!
  @IBOutlet weak var unitTypeControl: UISegmentedControl!
  @IBOutlet weak var bottomDragHandle: UIVisualEffectView!
  
  let defaultContentHeight: CGFloat = 191
  
  // MARK: - Lifecycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Style handle
    self.bottomDragHandle.layer.cornerRadius = 3
    self.bottomDragHandle.layer.masksToBounds = true
    self.bottomDragHandle.clipsToBounds = true
    
    // Reload content
    self.reloadContent()
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: - Content
  
  func reloadContent() {
    
    // Unit type
    self.unitTypeControl.selectedSegmentIndex = Defaults.shared.unitType.rawValue
    
    // Version
    if let versionString = UIApplication.shared.versionString {
      self.versionLabel.text = "Version \(versionString)"
    } else {
      self.versionLabel.text = "Kozinga"
    }
  }
  
  // MARK: - Actions
  
  @IBAction func segmentedControlValueChanged(_ control: UISegmentedControl) {
    switch control {
    case self.unitTypeControl:
      if let unitType = UnitType(rawValue: control.selectedSegmentIndex) {
        Defaults.shared.unitType = unitType
        MyDataManager.shared.saveMainContext()
      }
    default: break
    }
  }
}
